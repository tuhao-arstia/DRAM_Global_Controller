////////////////////////////////////////////////////////////////////////
// Project Name: 
// Task Name   : DRAM Frontend Scheduler
// Module Name : frontend_scheduler
// File Name   : frontend_scheduler.sv
// Description : schedule issued commands
////////////////////////////////////////////////////////////////////////

`include "userType_pkg.sv"
`include "define.sv"
`include "request_fifo.sv"
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
                          o_frontend_command_valid,
                          o_frontend_command,
                          o_frontend_write_data,
                          o_frontend_write_data_last,
                          // backend controller to frontend scheduler
                          o_frontend_receive_ready,
                          i_returned_data_valid,
                          i_returned_data,
                          // frontend scheduler to interconnection
                          i_interconnection_ready,
                          o_scheduler_request_valid,
                          o_scheduler_read_data,
                          o_scheduler_read_data_last,
                          o_scheduler_request_ID,
                          o_scheduler_core_id, 
);

input logic i_clk;
input logic i_rst_n;

input logic i_interconnection_request_valid;
input frontend_interconnection_request_t i_interconnection_request;
input logic [`FRONTEND_WORD_SIZE-1:0] i_interconnection_write_data;
input logic i_interconnection_write_data_last;

// input buffer
frontend_interconnection_request_t interconnection_request;
logic [`FRONTEND_WORD_SIZE-1:0] interconnection_write_data [0:3];
logic interconnection_write_data_last;

logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS-1:0] write_addr;


// RAW related
// {valid_bit, addr}
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS:0] raw_info [0:7];
logic raw_valid [0:7];
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS-1:0] raw_addr [0:7];
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS-1:0] raw_current_addr;
logic raw_flag;


//---------------------------------------//
// Interconnection to Frontend Scheduler //
//---------------------------------------//




// busy flag to not to accept new command when the scheduler is busy

always_ff @(posedge i_clk or negedge i_rst_n) 
begin: INPUT_COMMAND
    if(!i_rst_n) 
    begin
        interconnection_request <= 0;
    end
    else if (i_interconnection_request_valid)
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
    else if(i_interconnection_request_valid && i_interconnection_request.op_type == 1'b1)
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
        interconnection_write_data_last <= i_interconnection_write_data_last;
    end
end

// read after write detection


// read request fifo
request_fifo #(.DATA_WIDTH(1), .FIFO_DEPTH(4)) read_request_fifo (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data(interconnection_request.command.op_type),
    .wr_en(),
    .rd_en(),
    .o_data(n_read_request),
    .o_full(),
    .o_empty()
);

// write request fifo

// write data fifo

// write address fifo
assign write_addr = {interconnection_request.command.bank_addr, interconnection_request.command.row_addr, interconnection_request.command.col_addr};
write_addr_fifo #(.DATA_WIDTH(`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS), .FIFO_DEPTH(4)) write_addr_fifo (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data(write_addr),
    .wr_en(interconnection_write_data_last && interconnection_request.command.op_type == 1'b0),
    .rd_en(),
    .o_addr_0(raw_info[0]),
    .o_addr_1(raw_info[1]),
    .o_addr_2(raw_info[2]),
    .o_addr_3(raw_info[3]),
    .o_addr_4(raw_info[4]),
    .o_addr_5(raw_info[5]),
    .o_addr_6(raw_info[6]),
    .o_addr_7(raw_info[7]),
    .o_full(),
    .o_empty()
);

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
        if(raw_valid[7] && raw_addr[7] == raw_current_addr)
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
        end else
        begin
            raw_flag = 0;
        end
    end else
    begin
        raw_flag = 0;
    end
end



endmodule

