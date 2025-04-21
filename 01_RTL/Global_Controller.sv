////////////////////////////////////////////////////////////////////////
// Project Name: 
// Task Name   : DRAM Global Controller
// Module Name : Global_Controller
// File Name   : Global_Controller.sv
////////////////////////////////////////////////////////////////////////

`include "write_addr_fifo.sv"
`include "write_request_fifo.sv"
`include "DW_fifo_s1_df.v"

`define GLOBAL_CONTROLLER_WORD_SIZE 1024

module Global_Controller(
                          i_clk,
                          i_rst_n,
                          
                          // request channel
                          i_command_valid,
                          i_command,
                          i_write_data,
                          o_controller_ready,

                          // read data channel
                          o_read_data_valid,
                          o_read_data,

                          // command channel
                          i_backend_controller_ready_bc0,
                          o_frontend_command_valid_bc0,
                          o_frontend_command_bc0,
                          o_frontend_write_data_bc0,

                          i_backend_controller_ready_bc1,
                          o_frontend_command_valid_bc1,
                          o_frontend_command_bc1,
                          o_frontend_write_data_bc1,

                          i_backend_controller_ready_bc2,
                          o_frontend_command_valid_bc2,
                          o_frontend_command_bc2,
                          o_frontend_write_data_bc2,

                          i_backend_controller_ready_bc3,
                          o_frontend_command_valid_bc3,
                          o_frontend_command_bc3,
                          o_frontend_write_data_bc3,
                          // returned data channel
                          o_backend_controller_ren_bc0,
                          i_returned_data_valid_bc0,
                          i_returned_data_bc0,

                          o_backend_controller_ren_bc1,
                          i_returned_data_valid_bc1,
                          i_returned_data_bc1,

                          o_backend_controller_ren_bc2,
                          i_returned_data_valid_bc2,
                          i_returned_data_bc2,

                          o_backend_controller_ren_bc3,
                          i_returned_data_valid_bc3,
                          i_returned_data_bc3
);

input logic i_clk;
input logic i_rst_n;

// request channel
input logic i_command_valid;
input frontend_command_t i_command;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_write_data;
output logic o_controller_ready;

// read data channel
output logic o_read_data_valid;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_read_data;

// command channel
input logic i_backend_controller_ready_bc0;
output logic o_frontend_command_valid_bc0;
output backend_command_t o_frontend_command_bc0;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_frontend_write_data_bc0;

input logic i_backend_controller_ready_bc1;
output logic o_frontend_command_valid_bc1;
output backend_command_t o_frontend_command_bc1;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_frontend_write_data_bc1;

input logic i_backend_controller_ready_bc2;
output logic o_frontend_command_valid_bc2;
output backend_command_t o_frontend_command_bc2;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_frontend_write_data_bc2;

input logic i_backend_controller_ready_bc3;
output logic o_frontend_command_valid_bc3;
output backend_command_t o_frontend_command_bc3;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_frontend_write_data_bc3;

 // returned data channel
output logic o_backend_controller_ren_bc0;
input logic i_returned_data_valid_bc0;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_returned_data_bc0;

output logic o_backend_controller_ren_bc1;
input logic i_returned_data_valid_bc1;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_returned_data_bc1;

output logic o_backend_controller_ren_bc2;
input logic i_returned_data_valid_bc2;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_returned_data_bc2;

output logic o_backend_controller_ren_bc3;
input logic i_returned_data_valid_bc3;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_returned_data_bc3;

//----------------------------------------------------//
//                    Declaration                     //
//----------------------------------------------------//
parameter write_data_width = `GLOBAL_CONTROLLER_WORD_SIZE;
parameter command_width = `OP_BITS+`DATA_TYPE_BITS+`ROW_BITS+`COL_BITS+`BANK_BITS;
parameter bank_addr_width = `BANK_BITS;
parameter fifo_depth = 8;
parameter ae_level = 1;
parameter af_level = 1;
parameter af_level_write_request = 4; // 12 write requests
parameter err_mode = 0;
parameter rst_mode = 0;
integer i;


// REQUEST CHANNEL
logic hs_request_channel;

frontend_command_t command;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] write_data;

// read/write request fifos
logic read_request_wr_en, write_request_wr_en;
logic read_request_rd_en, write_request_rd_en;
logic read_request_fifo_full, write_request_fifo_full;
logic read_request_fifo_empty, write_request_fifo_empty;
logic read_request_fifo_error, write_request_fifo_error;
logic write_flush;
frontend_command_t read_request_candidate;
frontend_command_t write_request_candidate;

// scheduled request fifo
logic scheduled_request_rd_en, scheduled_request_wr_en;
logic scheduled_request_fifo_full, scheduled_request_fifo_empty;
logic scheduled_request_fifo_error;
frontend_command_t scheduled_request_fifo_in, scheduled_request_fifo_out;

// write data fifo 
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] write_data_fifo_out;
logic write_data_fifo_full, write_data_fifo_empty;
logic write_data_fifo_error;

// scheduled write data fifo
logic scheduled_write_data_rd_en, scheduled_write_data_wr_en;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] scheduled_write_data_fifo_out;
logic scheduled_write_data_fifo_full, scheduled_write_data_fifo_empty;
logic scheduled_write_data_fifo_error;

// write address fifo (RAW related)
logic [`ROW_BITS+`COL_BITS+`BANK_BITS-1:0] write_addr;
logic write_addr_fifo_full, write_addr_fifo_empty;
// raw_info = {valid_bit, addr}
logic [`ROW_BITS+`COL_BITS+`BANK_BITS:0] raw_info [0:7];
logic raw_valid [0:7];
logic [`ROW_BITS+`COL_BITS+`BANK_BITS-1:0] raw_addr [0:7];
logic [`ROW_BITS+`COL_BITS+`BANK_BITS-1:0] raw_current_addr;
logic raw_flag;

// returned data channel
logic hs_returned_data_channel_0;
logic hs_returned_data_channel_1;
logic hs_returned_data_channel_2;
logic hs_returned_data_channel_3;
// read order fifo
logic [`BANK_BITS-1:0] read_order_fifo_in, read_order_fifo_out;
logic read_order_wr_en, read_order_rd_en;
logic read_order_fifo_full, read_order_fifo_empty;
logic read_order_fifo_error;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] returned_data;


//----------------------------------------------------//
//              Global Controller DESIGN              //
//----------------------------------------------------//
//---------------------------------------//
//            Request Channel            //
//---------------------------------------//
assign hs_request_channel = i_command_valid && o_controller_ready;

assign command = i_command;
// always_ff @(posedge i_clk or negedge i_rst_n) 
// begin: I_COMMAND
    // if(!i_rst_n) 
    // begin
        // command <= 0;
    // end
    // else if (hs_request_channel)
    // begin
        // command <= i_command;
    // end
    // else
    // begin
        // command <= 0;
    // end
// end

assign write_data = i_write_data;
// always_ff @(posedge i_clk or negedge i_rst_n)
// begin: I_WRITE_DATA
    // if(!i_rst_n)
    // begin
        // write_data <= 0;
    // end
    // else if(hs_request_channel && i_command.op_type == OP_WRITE)
    // begin
        // write_data <= i_write_data;
    // end
    // else
    // begin
        // write_data <= 0;
    // end
// end

// o_controller_ready
// check this one later
assign o_controller_ready = !read_request_fifo_full && !write_request_fifo_full && !write_flush;

//------------------------------------------//
//             Command Channel              //
//------------------------------------------//
// read request fifo
DW_fifo_s1_sf #(command_width, fifo_depth, ae_level, af_level, err_mode, rst_mode)
read_request_fifo (
    .clk(i_clk),
    .rst_n(i_rst_n),
    .push_req_n(~read_request_wr_en),
    .pop_req_n(~read_request_rd_en),
    .diag_n(1'b1),
    .data_in(command),
    .empty(read_request_fifo_empty),
    .almost_empty(),
    .half_full(),
    .almost_full(),
    .full(read_request_fifo_full),
    .error(read_request_fifo_error),
    .data_out(read_request_candidate)
);


assign read_request_wr_en = (command.op_type == OP_READ) && hs_request_channel;
// always_ff @(posedge i_clk or negedge i_rst_n)
// begin :READ_REQUEST_WR_EN
    // if(!i_rst_n)
    // begin
        // read_request_wr_en <= 0;
    // end
    // else
    // begin
        // read_request_wr_en <= (command.op_type == OP_READ);
    // end
// end

always_comb
begin : READ_REQUEST_FIFO_RD_EN
    read_request_rd_en = 0;
    if(!read_request_fifo_empty)
    begin
        if(write_flush && !write_request_fifo_empty)
        begin
            read_request_rd_en = 0;
        end
        else if(!scheduled_request_fifo_full)
        begin
            read_request_rd_en = 1;
        end
        else
        begin
            read_request_rd_en = (o_frontend_command_valid_bc0 || o_frontend_command_valid_bc1 || o_frontend_command_valid_bc2 || o_frontend_command_valid_bc3);
        end
    end
end
// always_ff @(posedge i_clk or negedge i_rst_n)
// begin : READ_REQUEST_FIFO_RD_EN
    // if (!i_rst_n)
    // begin
        // read_request_rd_en <= 0;
    // end
    // else
    // begin
        // if (!scheduled_request_fifo_full && !read_request_fifo_empty)
        // begin
            // if (write_flush && !write_request_fifo_empty)
            // begin
                // read_request_rd_en <= 0;
            // end
            // else
            // begin
                // read_request_rd_en <= 1;
            // end
        // end
        // else
        // begin
            // read_request_rd_en <= 0;
        // end
    // end
// end

// write request fifo: see write_request_fifo.sv
write_request_fifo write_request_fifo (
    .clk(i_clk),
    .rst_n(i_rst_n),
    .push_req_n(write_request_wr_en),
    .pop_req_n(write_request_rd_en),
    .data_in(command),
    .raw_flag(raw_flag),
    .empty(write_request_fifo_empty),
    .full(write_request_fifo_full),
    .error(write_request_fifo_error),
    .data_out(write_request_candidate),
    .write_flush_flag(write_flush)
);

assign write_request_wr_en = (command.op_type == OP_WRITE) && hs_request_channel ;
// always_ff @(posedge i_clk or negedge i_rst_n)
// begin : WRITE_REQUEST_WR_EN
    // if (!i_rst_n)
    // begin
        // write_request_wr_en <= 0;
    // end
    // else
    // begin
        // write_request_wr_en <= (command.op_type == OP_WRITE);
    // end
// end

always_comb
begin : WRITE_REQUEST_FIFO_RD_EN
    write_request_rd_en = 0;

    if(!write_request_fifo_empty)
    begin
        if(write_flush || read_request_fifo_empty)
        begin
            if(!scheduled_request_fifo_full)
            begin
                write_request_rd_en = 1;
            end
            else
            begin
                write_request_rd_en = (o_frontend_command_valid_bc0 || o_frontend_command_valid_bc1 || o_frontend_command_valid_bc2 || o_frontend_command_valid_bc3);
            end
        end
    end
end
// always_ff @(posedge i_clk or negedge i_rst_n)
// begin : WRITE_REQUEST_FIFO_RD_EN
    // if (!i_rst_n)
    // begin
        // write_request_rd_en <= 0;
    // end
    // else
    // begin
        // if (!scheduled_request_fifo_full && !write_request_fifo_empty)
        // begin
            // if (write_flush || read_request_fifo_empty)
            // begin
                // write_request_rd_en <= 1;
            // end
            // else
            // begin
                // write_request_rd_en <= 0;
            // end
        // end
        // else
        // begin
            // write_request_rd_en <= 0;
        // end
    // end
// end

// scheduled request fifo
DW_fifo_s1_sf #(command_width, fifo_depth, ae_level, af_level, err_mode, rst_mode)
scheduled_request_fifo (
    .clk(i_clk),
    .rst_n(i_rst_n),
    .push_req_n(~scheduled_request_wr_en),
    .pop_req_n(~scheduled_request_rd_en),
    .diag_n(1'b1),
    .data_in(scheduled_request_fifo_in),
    .empty(scheduled_request_fifo_empty),
    .almost_empty(),
    .half_full(),
    .almost_full(),
    .full(scheduled_request_fifo_full),
    .error(scheduled_request_fifo_error),
    .data_out(scheduled_request_fifo_out)
);

assign scheduled_request_wr_en = !read_request_fifo_empty || !write_request_fifo_empty && !scheduled_request_fifo_full;

always_comb
begin : SCHEDULED_REQUEST_FIFO_RD_EN
    scheduled_request_rd_en = 0;

    if(!scheduled_request_fifo_empty)
    begin
        case (scheduled_request_fifo_out.bank_addr)
            2'b00: begin
                scheduled_request_rd_en = i_backend_controller_ready_bc0;
            end
            2'b01: begin
                scheduled_request_rd_en = i_backend_controller_ready_bc1;
            end
            2'b10: begin
                scheduled_request_rd_en = i_backend_controller_ready_bc2;
            end
            2'b11: begin
                scheduled_request_rd_en = i_backend_controller_ready_bc3;
            end
        endcase
    end
end

always_comb
begin :SCHEDULED_REQUEST_FIFO_IN
    scheduled_request_fifo_in = 0;

    if(!read_request_fifo_empty)
    begin
        if(write_flush && !write_request_fifo_empty)
        begin
            scheduled_request_fifo_in = write_request_candidate;
        end
        else
        begin
            scheduled_request_fifo_in = read_request_candidate;
        end
    end
    else if(!write_request_fifo_empty)
    begin
        scheduled_request_fifo_in = write_request_candidate;
    end
end

// write data fifo
DW_fifo_s1_sf #(write_data_width, fifo_depth, ae_level, af_level, err_mode, rst_mode)
write_data_fifo (
    .clk(i_clk),
    .rst_n(i_rst_n),
    .push_req_n(~write_request_wr_en),
    .pop_req_n(~write_request_rd_en),
    .diag_n(1'b1),
    .data_in(write_data),
    .empty(write_data_fifo_empty),
    .almost_empty(),
    .half_full(),
    .almost_full(),
    .full(write_data_fifo_full),
    .error(write_data_fifo_error),
    .data_out(write_data_fifo_out)
);

// scheduled write data fifo
DW_fifo_s1_sf #(write_data_width, fifo_depth, ae_level, af_level, err_mode, rst_mode)
scheduled_write_data_fifo (
    .clk(i_clk),
    .rst_n(i_rst_n),
    .push_req_n(~scheduled_write_data_wr_en),
    .pop_req_n(~scheduled_write_data_rd_en),
    .diag_n(1'b1),
    .data_in(write_data_fifo_out),
    .empty(scheduled_write_data_fifo_empty),
    .almost_empty(),
    .half_full(),
    .almost_full(),
    .full(scheduled_write_data_fifo_full),
    .error(scheduled_write_data_fifo_error),
    .data_out(scheduled_write_data_fifo_out)
);

always_comb
begin : SCHEDULED_WRITE_DATA_FIFO_WR_EN
    scheduled_write_data_wr_en = 0;

    // condition is same as scheduled_request_fifo_in
    if(!scheduled_request_fifo_full)
    begin
        if(!read_request_fifo_empty)
        begin
            if(write_flush && !write_request_fifo_empty)
            begin
                scheduled_write_data_wr_en = 1;
            end
        end
        else if(!write_request_fifo_empty)
        begin
            scheduled_write_data_wr_en = 1;
        end
    end
end

always_comb 
begin : SCHEDULED_WRITE_DATA_FIFO_RD_EN
    scheduled_write_data_rd_en = 0;
    
    // could be a better design here?
    if(!scheduled_request_fifo_empty)
    begin
        if(scheduled_request_fifo_out.op_type == OP_WRITE)
        begin
            scheduled_write_data_rd_en = scheduled_request_rd_en;
        end
    end
    
end

// write address fifo
write_addr_fifo #(.DATA_WIDTH(`ROW_BITS+`COL_BITS+`BANK_BITS), .FIFO_DEPTH(4)) 
write_addr_fifo (
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

assign write_addr = {command.row_addr, command.col_addr, command.bank_addr};

// RAW detection 
assign raw_current_addr = {command.row_addr, command.col_addr, command.bank_addr};
always_comb 
begin: RAW_INFO_DECODE
    for(i = 0; i < 8; i = i + 1)
    begin
       raw_addr[i] = raw_info[i][`ROW_BITS+`COL_BITS+`BANK_BITS-1:0];
       raw_valid[i] = raw_info[i][`ROW_BITS+`COL_BITS+`BANK_BITS]; 
    end
end

always_comb
begin:RAW_DETECTION
    if(command.op_type == OP_READ && !write_request_fifo_empty)
    begin
        // 7 is the latest write pointer position
        if(raw_valid[7] && raw_addr[7] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[6] && raw_addr[6] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[5] && raw_addr[5] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[4] && raw_addr[4] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[3] && raw_addr[3] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[2] && raw_addr[2] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[1] && raw_addr[1] == raw_current_addr)
        begin
            raw_flag = 1;
        end
        else if(raw_valid[0] && raw_addr[0] == raw_current_addr)
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

// command channels output logics
// o_frontend_command_valid_bc0 - bc3
always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : O_FRONTEND_COMMAND_VALID_BC0
    if(!i_rst_n) 
    begin
        o_frontend_command_valid_bc0 <= 0;
    end
    else if(!scheduled_request_fifo_empty)
    begin
        if(i_backend_controller_ready_bc0 && scheduled_request_fifo_out.bank_addr == 2'b00)
        begin
            o_frontend_command_valid_bc0 <= 1;
        end
        else
        begin
            o_frontend_command_valid_bc0 <= 0;
        end
    end
    else 
    begin
        o_frontend_command_valid_bc0 <= 0;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : O_FRONTEND_COMMAND_VALID_BC1
    if(!i_rst_n) 
    begin
        o_frontend_command_valid_bc1 <= 0;
    end
    else if(!scheduled_request_fifo_empty)
    begin
        if(i_backend_controller_ready_bc1 && scheduled_request_fifo_out.bank_addr == 2'b01)
        begin
            o_frontend_command_valid_bc1 <= 1;
        end
        else
        begin
            o_frontend_command_valid_bc1 <= 0;
        end
    end
    else 
    begin
        o_frontend_command_valid_bc1 <= 0;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : O_FRONTEND_COMMAND_VALID_BC2
    if(!i_rst_n) 
    begin
        o_frontend_command_valid_bc2 <= 0;
    end
    else if(!scheduled_request_fifo_empty)
    begin
        if(i_backend_controller_ready_bc2 && scheduled_request_fifo_out.bank_addr == 2'b10)
        begin
            o_frontend_command_valid_bc2 <= 1;
        end
        else
        begin
            o_frontend_command_valid_bc2 <= 0;
        end
    end
    else 
    begin
        o_frontend_command_valid_bc2 <= 0;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : O_FRONTEND_COMMAND_VALID_BC3
    if(!i_rst_n) 
    begin
        o_frontend_command_valid_bc3 <= 0;
    end
    else if(!scheduled_request_fifo_empty)
    begin
        if(i_backend_controller_ready_bc3 && scheduled_request_fifo_out.bank_addr == 2'b11)
        begin
            o_frontend_command_valid_bc3 <= 1;
        end
        else
        begin
            o_frontend_command_valid_bc3 <= 0;
        end
    end
    else 
    begin
        o_frontend_command_valid_bc3 <= 0;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : O_FRONTEND_COMMAND
    if(!i_rst_n) 
    begin
        o_frontend_command_bc0.op_type <= OP_WRITE;
        o_frontend_command_bc0.data_type <= DATA_TYPE_WEIGHTS;
        o_frontend_command_bc0.row_addr <= 0;
        o_frontend_command_bc0.col_addr <= 0;

        o_frontend_command_bc1.op_type <= OP_WRITE;
        o_frontend_command_bc1.data_type <= DATA_TYPE_WEIGHTS;
        o_frontend_command_bc1.row_addr <= 0;
        o_frontend_command_bc1.col_addr <= 0;

        o_frontend_command_bc2.op_type <= OP_WRITE;
        o_frontend_command_bc2.data_type <= DATA_TYPE_WEIGHTS;
        o_frontend_command_bc2.row_addr <= 0;
        o_frontend_command_bc2.col_addr <= 0;

        o_frontend_command_bc3.op_type <= OP_WRITE;
        o_frontend_command_bc3.data_type <= DATA_TYPE_WEIGHTS;
        o_frontend_command_bc3.row_addr <= 0;
        o_frontend_command_bc3.col_addr <= 0;
    end
    else
    begin
        o_frontend_command_bc0.op_type <= scheduled_request_fifo_out.op_type;
        o_frontend_command_bc0.data_type <= scheduled_request_fifo_out.data_type;
        o_frontend_command_bc0.row_addr <= scheduled_request_fifo_out.row_addr;
        o_frontend_command_bc0.col_addr <= scheduled_request_fifo_out.col_addr;

        o_frontend_command_bc1.op_type <= scheduled_request_fifo_out.op_type;
        o_frontend_command_bc1.data_type <= scheduled_request_fifo_out.data_type;
        o_frontend_command_bc1.row_addr <= scheduled_request_fifo_out.row_addr;
        o_frontend_command_bc1.col_addr <= scheduled_request_fifo_out.col_addr;

        o_frontend_command_bc2.op_type <= scheduled_request_fifo_out.op_type;
        o_frontend_command_bc2.data_type <= scheduled_request_fifo_out.data_type;
        o_frontend_command_bc2.row_addr <= scheduled_request_fifo_out.row_addr;
        o_frontend_command_bc2.col_addr <= scheduled_request_fifo_out.col_addr;

        o_frontend_command_bc3.op_type <= scheduled_request_fifo_out.op_type;
        o_frontend_command_bc3.data_type <= scheduled_request_fifo_out.data_type;
        o_frontend_command_bc3.row_addr <= scheduled_request_fifo_out.row_addr;
        o_frontend_command_bc3.col_addr <= scheduled_request_fifo_out.col_addr;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : O_FRONTEND_WRITE_DATA
    if(!i_rst_n) 
    begin
        o_frontend_write_data_bc0 <= 0;
        o_frontend_write_data_bc1 <= 0;
        o_frontend_write_data_bc2 <= 0;
        o_frontend_write_data_bc3 <= 0;
    end
    else
    begin
        o_frontend_write_data_bc0 <= scheduled_write_data_fifo_out;
        o_frontend_write_data_bc1 <= scheduled_write_data_fifo_out;
        o_frontend_write_data_bc2 <= scheduled_write_data_fifo_out;
        o_frontend_write_data_bc3 <= scheduled_write_data_fifo_out;
    end
end


//------------------------------------------//
//          Returned Data Channel           //
//------------------------------------------//
assign hs_returned_data_channel_0 = i_returned_data_valid_bc0 && o_backend_controller_ren_bc0;
assign hs_returned_data_channel_1 = i_returned_data_valid_bc1 && o_backend_controller_ren_bc1;
assign hs_returned_data_channel_2 = i_returned_data_valid_bc2 && o_backend_controller_ren_bc2;
assign hs_returned_data_channel_3 = i_returned_data_valid_bc3 && o_backend_controller_ren_bc3;

// read order fifo
DW_fifo_s1_sf #(bank_addr_width, fifo_depth, ae_level, af_level, err_mode, rst_mode)
read_order_fifo (
    .clk(i_clk),
    .rst_n(i_rst_n),
    .push_req_n(~read_order_wr_en),
    .pop_req_n(~read_order_rd_en),
    .diag_n(1'b1),
    .data_in(read_order_fifo_in),
    .empty(read_order_fifo_empty),
    .almost_empty(),
    .half_full(),
    .almost_full(),
    .full(read_order_fifo_full),
    .error(read_order_fifo_error),
    .data_out(read_order_fifo_out)
);

always_comb 
begin : READ_ORDER_FIFO_WR_EN
    read_order_wr_en = 0;
    if(!scheduled_request_fifo_empty)
    begin
        if(scheduled_request_fifo_out.op_type == OP_READ)
        begin
            read_order_wr_en = scheduled_request_rd_en;
        end
    end
end

always_comb
begin : READ_ORDER_FIFO_RD_EN
    read_order_rd_en = 0;
    
    if(hs_returned_data_channel_0 || hs_returned_data_channel_1 || hs_returned_data_channel_2 || hs_returned_data_channel_3)
    begin
        read_order_rd_en = 1;
    end
end

/////////
// returned data channel output logic
always_comb
begin : O_BACKEND_CONTROLLER_REN_BC0
    o_backend_controller_ren_bc0 = 0;

    if(!read_order_fifo_empty)
    begin
        if(read_order_fifo_out == 2'b00)
        begin
            o_backend_controller_ren_bc0 = 1;
        end
    end
end

always_comb
begin : O_BACKEND_CONTROLLER_REN_BC1
    o_backend_controller_ren_bc1 = 0;

    if(!read_order_fifo_empty)
    begin
        if(read_order_fifo_out == 2'b01)
        begin
            o_backend_controller_ren_bc1 = 1;
        end
    end
end

always_comb
begin : O_BACKEND_CONTROLLER_REN_BC2
    o_backend_controller_ren_bc2 = 0;

    if(!read_order_fifo_empty)
    begin
        if(read_order_fifo_out == 2'b10)
        begin
            o_backend_controller_ren_bc2 = 1;
        end
    end
end

always_comb
begin : O_BACKEND_CONTROLLER_REN_BC3
    o_backend_controller_ren_bc3 = 0;

    if(!read_order_fifo_empty)
    begin
        if(read_order_fifo_out == 2'b11)
        begin
            o_backend_controller_ren_bc3 = 1;
        end
    end
end

// returned data
always_ff @(posedge i_clk or negedge i_rst_n)
begin : RETURNED_DATA
    if(!i_rst_n) 
    begin
        returned_data <= 0;
    end
    else if(hs_returned_data_channel_0)
    begin
        returned_data <= i_returned_data_bc0;
    end
    else if(hs_returned_data_channel_1)
    begin
        returned_data <= i_returned_data_bc1;
    end
    else if(hs_returned_data_channel_2)
    begin
        returned_data <= i_returned_data_bc2;
    end
    else if(hs_returned_data_channel_3)
    begin
        returned_data <= i_returned_data_bc3;
    end
    else 
    begin
        returned_data <= 0;
    end
end

//------------------------------------------//
//             Read Data Channel            //
//------------------------------------------//
always_ff @(posedge i_clk or negedge i_rst_n)
begin : O_READ_DATA_VALID
    if(!i_rst_n) 
    begin
        o_read_data_valid <= 0;
    end
    else
    begin
        o_read_data_valid <= (hs_returned_data_channel_0 || hs_returned_data_channel_1 || hs_returned_data_channel_2 || hs_returned_data_channel_3);
    end
end

always_ff @(posedge i_clk or negedge i_rst_n)
begin : O_READ_DATA
    if(!i_rst_n) 
    begin
        o_read_data <= 0;
    end
    else
    begin
        o_read_data <= returned_data;
    end
end



endmodule

