////////////////////////////////////////////////////////////////////////
// Project Name: 
// Task Name   : DRAM Frontend Scheduler
// Module Name : frontend_scheduler
// File Name   : frontend_scheduler.sv
// Description : schedule issued commands
////////////////////////////////////////////////////////////////////////

`include "userType_pkg.sv"
`include "define.sv"
`include "read_request_fifo.sv"
`include "write_request_fifo.sv"
`include "write_data_fifo.sv"
`include "write_addr_fifo.sv"

import usertype::*;
import frontend_command_definition_pkg::*;

module frontend_scheduler(
                          i_clk,
                          i_rst_n,
                          // interconnection to frontend scheduler
                          o_scheduler_ready,
                          i_interconnection_request_valid,
                          i_interconnection_request,
                          i_interconnection_write_data,
                          i_interconnection_write_data_last,
                          // frontend scheduler to backend controller
                          i_backend_controller_ready,
                          i_backend_controller_wdata_rd_en,
                          o_frontend_command_valid,
                          o_frontend_command,
                          o_frontend_write_data,
                          o_frontend_write_data_last,
                          o_stall_backend_controller,
                          // backend controller to frontend scheduler
                          o_frontend_receive_ready,
                          i_returned_data_valid,
                          i_returned_data,
                          // frontend scheduler to interconnection
                          i_interconnection_ready,
                          o_scheduler_request_valid,
                          o_scheduler_read_data,
                          o_scheduler_read_data_last,
                          o_scheduler_request_id,
                          o_scheduler_core_num, 
);

input logic i_clk;
input logic i_rst_n;

input logic i_interconnection_request_valid;
input frontend_interconnection_request_t i_interconnection_request;
input logic [`FRONTEND_WORD_SIZE-1:0] i_interconnection_write_data;
input logic i_interconnection_write_data_last;
output logic o_scheduler_ready;

input logic i_backend_controller_ready;
input logic i_backend_controller_wdata_rd_en;

// transaction signals
// handshake signals
logic hs_interconnection_to_frontend_scheduler;

// input buffer
frontend_interconnection_request_t interconnection_request;
logic [`FRONTEND_WORD_SIZE-1:0] interconnection_write_data [0:3];
logic interconnection_write_data_last;

// request fifos
logic read_request_wr_en, write_request_wr_en;
logic read_request_rd_en, write_request_rd_en;
logic read_request_fifo_full, write_request_fifo_full;
logic read_request_fifo_empty, write_request_fifo_empty;
logic write_flush;
frontend_command_t read_request_candidate;
frontend_command_t write_request_candidate;

// write data fifo 
logic [`BACKEND_WORD_SIZE-1:0] write_data_fifo_in;
logic [`BACKEND_WORD_SIZE-1:0] write_data_fifo_out;
logic write_data_fifo_full, write_data_fifo_empty;

// write address fifo (RAW related)
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS-1:0] write_addr;
logic write_addr_fifo_full, write_addr_fifo_empty;
// raw_info = {valid_bit, addr}
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS:0] raw_info [0:7];
logic raw_valid [0:7];
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS-1:0] raw_addr [0:7];
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS-1:0] raw_current_addr;
logic raw_flag;

// output logics
logic n_o_scheduler_ready;

//---------------------------------------//
// Interconnection to Frontend Scheduler //
//---------------------------------------//
assign hs_interconnection_to_frontend_scheduler = i_interconnection_request_valid && o_scheduler_ready;

always_ff @(posedge i_clk or negedge i_rst_n) 
begin: INPUT_COMMAND
    if(!i_rst_n) 
    begin
        interconnection_request <= 0;
    end
    else if (hs_interconnection_to_frontend_scheduler)
    begin
        interconnection_request <= i_interconnection_request;
    end
    else
    begin
        interconnection_request <= 0;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n)
begin: INPUT_WRITE_DATA
    if(!i_rst_n)
    begin
        interconnection_write_data[3] <= 0;
        interconnection_write_data[2] <= 0;
        interconnection_write_data[1] <= 0;
        interconnection_write_data[0] <= 0;
    end
    else if(hs_interconnection_to_frontend_scheduler && i_interconnection_request.op_type == 1'b1)
    begin
        interconnection_write_data[3] <= interconnection_write_data[2];
        interconnection_write_data[2] <= interconnection_write_data[1];
        interconnection_write_data[1] <= interconnection_write_data[0];
        interconnection_write_data[0] <= i_interconnection_write_data;
    end
    else
    begin
        interconnection_write_data[3] <= interconnection_write_data[2];
        interconnection_write_data[2] <= interconnection_write_data[1];
        interconnection_write_data[1] <= interconnection_write_data[0];
        interconnection_write_data[0] <= 0;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n)
begin: INPUT_WRITE_DATA_LAST
    if(!i_rst_n)
    begin
        interconnection_write_data_last <= 0;
    end
    else
    begin
        // write_data_last must occur after handshake
        interconnection_write_data_last <= i_interconnection_write_data_last;
    end
end


// read request fifo
read_request_fifo #(.DATA_WIDTH(`BANK_ADDR_BITS+`ROW_ADDR_BITS+`COL_ADDR_BITS+2), .FIFO_DEPTH(4)) read_request_fifo (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data(interconnection_request.command),
    .wr_en(read_request_wr_en),
    .rd_en(read_request_rd_en),
    .o_data(read_request_candidate),
    .o_full(read_request_fifo_full),
    .o_empty(read_request_fifo_empty),
);

assign read_request_wr_en = (interconnection_request.command.op_type == 1'b1);

// change to sequential logic if needed
always_comb
begin : READ_REQUEST_FIFO_RD_EN
    if(i_backend_controller_ready && !read_request_empty)
    begin
        if( !(write_flush && !write_request_empty) )
        begin
            read_request_rd_en = 1;
        end
        else
        begin
            read_request_rd_en = 0;
        end
    end
    else
    begin
        read_request_rd_en = 0;
    end
end


// write request fifo
write_request_fifo #(.DATA_WIDTH(`BANK_ADDR_BITS+`ROW_ADDR_BITS+`COL_ADDR_BITS+2), .FIFO_DEPTH(4), .FLUSH_WATERMARK(12)) write_request_fifo (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data(interconnection_request.command),
    .i_raw_flag(raw_flag),
    .wr_en(write_request_wr_en),
    .rd_en(write_request_rd_en),
    .o_data(write_request_candidate),
    .o_full(write_request_fifo_full),
    .o_empty(write_request_fifo_empty),
    .o_write_flush(write_flush)
);

assign write_request_wr_en = interconnection_write_data_last;

always_comb
begin : WRITE_REQUEST_FIFO_RD_EN
    if(i_backend_controller_ready && !write_request_empty)
    begin
        if(read_request_empty || write_flush)
        begin
            write_request_rd_en = 1;
        end
        else
        begin
            write_request_rd_en = 0;
        end
    end
    else
    begin
        write_request_rd_en = 0;
    end
end


// write data fifo
write_data_fifo #(.DATA_WIDTH(`BACKEND_WORD_SIZE), .FIFO_DEPTH(4)) write_data_fifo (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data(write_data_fifo_in),
    .wr_en(write_request_wr_en),
    .rd_en(i_backend_controller_wdata_rd_en),
    .o_data(write_data_fifo_out),
    .o_full(write_data_fifo_full),
    .o_empty(write_data_fifo_empty),
);

assign write_data_fifo_in = {interconnection_write_data[3], interconnection_write_data[2], interconnection_write_data[1], interconnection_write_data[0]};

// write address fifo
write_addr_fifo #(.DATA_WIDTH(`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS), .FIFO_DEPTH(4)) write_addr_fifo (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data(write_addr),
    .wr_en(write_request_wr_en),
    .rd_en(write_request_rd_en),
    .o_addr_0(raw_info[0]),
    .o_addr_1(raw_info[1]),
    .o_addr_2(raw_info[2]),
    .o_addr_3(raw_info[3]),
    .o_addr_4(raw_info[4]),
    .o_addr_5(raw_info[5]),
    .o_addr_6(raw_info[6]),
    .o_addr_7(raw_info[7]),
    .o_full(write_addr_fifo_full),
    .o_empty(write_addr_fifo_empty)
);

assign write_addr = {interconnection_request.command.bank_addr, interconnection_request.command.row_addr, interconnection_request.command.col_addr};

// RAW detection 
assign raw_current_addr = {interconnection_request.command.bank_addr, interconnection_request.command.row_addr, interconnection_request.command.col_addr};
always_comb 
begin: RAW_INFO_DECODE
    for(i = 0; i < 8; i = i + 1)
    begin
       raw_addr[i] = raw_info[i][`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS-1:0];
       raw_valid[i] = raw_info[i][`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS]; 
    end
end

always_comb
begin:RAW_DETECTION
    if(interconnection_request.command.op_type == OP_READ)
    begin
        // 0 is the oldest read
        if(raw_valid[0] && raw_addr[0] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[1] && raw_addr[1] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[2] && raw_addr[2] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[3] && raw_addr[3] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[4] && raw_addr[4] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[5] && raw_addr[5] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[6] && raw_addr[6] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[7] && raw_addr[7] == raw_current_addr)
        begin
            raw_flag = 1;
        end 
        else
        begin
            raw_flag = 0;
        end
    end 
    else
    begin
        raw_flag = 0;
    end
end

// to do list : n_o_scheduler_ready logic


endmodule

