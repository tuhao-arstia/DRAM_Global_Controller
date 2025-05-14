////////////////////////////////////////////////////////////////////////
// Project Name:
// Task Name   : DRAM Global Controller
// Module Name : Global_Controller
// File Name   : Global_Controller.sv
////////////////////////////////////////////////////////////////////////

`include "DW_fifo_s1_df.v"

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
parameter fifo_depth = 2;
parameter read_order_fifo_depth = 16;
parameter ae_level = 1;
parameter af_level = 1;
parameter err_mode = 0;
parameter rst_mode = 0;
integer i;

// REQUEST CHANNEL
logic hs_request_channel;
// COMMAND CHANNEL TRANSACTION
logic command_transaction;
logic command_transaction_0;
logic command_transaction_1;
logic command_transaction_2;
logic command_transaction_3;
// RETURNED DATA CHANNEL TRANSACTION
logic returned_data_transaction;

frontend_command_t command;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] write_data;

// request fifo
logic request_rd_en, request_wr_en;
logic request_fifo_full, request_fifo_empty;
logic request_fifo_error;
frontend_command_t request_fifo_in, request_fifo_out;

// write data fifo
logic write_data_rd_en, write_data_wr_en;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] write_data_fifo_out;
logic write_data_fifo_full, write_data_fifo_empty;
logic write_data_fifo_error;

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

//----------------------------------------------------//
//              Global Controller DESIGN              //
//----------------------------------------------------//
//---------------------------------------//
//            Request Channel            //
//---------------------------------------//
assign hs_request_channel = (!i_rst_n)? 0 : i_command_valid && o_controller_ready;

assign command = i_command;

assign write_data = i_write_data;

// o_controller_ready
// assign o_controller_ready = (!request_fifo_full)? 1 : command_transaction;
// assign o_controller_ready = (!i_rst_n)? 0 : command_transaction;
always_comb
begin
    if(!i_rst_n)
    begin
        o_controller_ready = 0;
    end
    else
    begin
        o_controller_ready = command_transaction;
    end
end

//------------------------------------------//
//             Command Channel              //
//------------------------------------------//
// request fifo
// DW_fifo_s1_sf #(command_width, fifo_depth, ae_level, af_level, err_mode, rst_mode)
// request_fifo (
    // .clk(i_clk),
    // .rst_n(i_rst_n),
    // .push_req_n(~request_wr_en),
    // .pop_req_n(~request_rd_en),
    // .diag_n(1'b1),
    // .data_in(request_fifo_in),
    // .empty(request_fifo_empty),
    // .almost_empty(),
    // .half_full(),
    // .almost_full(),
    // .full(request_fifo_full),
    // .error(request_fifo_error),
    // .data_out(request_fifo_out)
// );
//
// always_comb
// begin : REQUEST_FIFO_WR_EN
    // request_wr_en = 0;
//
    // if(!request_fifo_full)
    // begin
        // request_wr_en = hs_request_channel;
    // end
    // else
    // begin
        // request_wr_en = hs_request_channel && command_transaction;
    // end
// end
//
// always_comb
// begin : REQUEST_FIFO_RD_EN
    // request_rd_en = 0;
//
    // if(!request_fifo_empty)
    // begin
        // case (request_fifo_out.bank_addr)
            // 2'b00: begin
                // request_rd_en = command_transaction_0;
            // end
            // 2'b01: begin
                // request_rd_en = command_transaction_1;
            // end
            // 2'b10: begin
                // request_rd_en = command_transaction_2;
            // end
            // 2'b11: begin
                // request_rd_en = command_transaction_3;
            // end
        // endcase
    // end
// end
//
// assign request_fifo_in = command;

// write data fifo
// DW_fifo_s1_sf #(write_data_width, fifo_depth, ae_level, af_level, err_mode, rst_mode)
// write_data_fifo (
    // .clk(i_clk),
    // .rst_n(i_rst_n),
    // .push_req_n(~write_data_wr_en),
    // .pop_req_n(~write_data_rd_en),
    // .diag_n(1'b1),
    // .data_in(write_data),
    // .empty(write_data_fifo_empty),
    // .almost_empty(),
    // .half_full(),
    // .almost_full(),
    // .full(write_data_fifo_full),
    // .error(write_data_fifo_error),
    // .data_out(write_data_fifo_out)
// );
//
// always_comb
// begin : WRITE_DATA_FIFO_WR_EN
    // write_data_wr_en = 0;
//
    // if(command.op_type == OP_WRITE)
    // begin
        // if(!request_fifo_full)
        // begin
            // write_data_wr_en = hs_request_channel;
        // end
        // else
        // begin
            // write_data_wr_en = hs_request_channel && command_transaction;
        // end
    // end
// end
//
// always_comb
// begin : WRITE_DATA_FIFO_RD_EN
    // write_data_rd_en = 0;
//
    // if(!request_fifo_empty)
    // begin
        // if(request_fifo_out.op_type == OP_WRITE)
        // begin
            // write_data_rd_en = request_rd_en;
        // end
    // end
// end

// command channels output logics
assign command_transaction_0 = i_backend_controller_ready_bc0 && o_frontend_command_valid_bc0;
assign command_transaction_1 = i_backend_controller_ready_bc1 && o_frontend_command_valid_bc1;
assign command_transaction_2 = i_backend_controller_ready_bc2 && o_frontend_command_valid_bc2;
assign command_transaction_3 = i_backend_controller_ready_bc3 && o_frontend_command_valid_bc3;
assign command_transaction = command_transaction_0 || command_transaction_1 || command_transaction_2 || command_transaction_3;

// o_frontend_command_valid logic rewritten as combinational logic
// always_comb
// begin : O_FRONTEND_COMMAND_VALID_BC0
    // o_frontend_command_valid_bc0 = 0;
    // if(!request_fifo_empty && !read_order_fifo_full)
    // begin
        // if(i_backend_controller_ready_bc0 && request_fifo_out.bank_addr == 2'b00)
        // begin
            // o_frontend_command_valid_bc0 = 1;
        // end
    // end
// end
//
// always_comb
// begin : O_FRONTEND_COMMAND_VALID_BC1
    // o_frontend_command_valid_bc1 = 0;
    // if(!request_fifo_empty && !read_order_fifo_full)
    // begin
        // if(i_backend_controller_ready_bc1 && request_fifo_out.bank_addr == 2'b01)
        // begin
            // o_frontend_command_valid_bc1 = 1;
        // end
    // end
// end
//
// always_comb
// begin : O_FRONTEND_COMMAND_VALID_BC2
    // o_frontend_command_valid_bc2 = 0;
    // if(!request_fifo_empty && !read_order_fifo_full)
    // begin
        // if(i_backend_controller_ready_bc2 && request_fifo_out.bank_addr == 2'b10)
        // begin
            // o_frontend_command_valid_bc2 = 1;
        // end
    // end
// end
//
// always_comb
// begin : O_FRONTEND_COMMAND_VALID_BC3
    // o_frontend_command_valid_bc3 = 0;
    // if(!request_fifo_empty && !read_order_fifo_full)
    // begin
        // if(i_backend_controller_ready_bc3 && request_fifo_out.bank_addr == 2'b11)
        // begin
            // o_frontend_command_valid_bc3 = 1;
        // end
    // end
// end

always_comb
begin : O_FRONTEND_COMMAND_VALID_BC0
    o_frontend_command_valid_bc0 = 0;
    if(!read_order_fifo_full)
    begin
        if(i_backend_controller_ready_bc0 && command.addr[1:0] == 2'b00)
        begin
            o_frontend_command_valid_bc0 = 1;
        end
    end
end

always_comb
begin : O_FRONTEND_COMMAND_VALID_BC1
    o_frontend_command_valid_bc1 = 0;
    if(!read_order_fifo_full)
    begin
        if(i_backend_controller_ready_bc1 && command.addr[1:0] == 2'b01)
        begin
            o_frontend_command_valid_bc1 = 1;
        end
    end
end

always_comb
begin : O_FRONTEND_COMMAND_VALID_BC2
    o_frontend_command_valid_bc2 = 0;
    if(!read_order_fifo_full)
    begin
        if(i_backend_controller_ready_bc2 && command.addr[1:0] == 2'b10)
        begin
            o_frontend_command_valid_bc2 = 1;
        end
    end
end

always_comb
begin : O_FRONTEND_COMMAND_VALID_BC3
    o_frontend_command_valid_bc3 = 0;
    if(!read_order_fifo_full)
    begin
        if(i_backend_controller_ready_bc3 && command.addr[1:0] == 2'b11)
        begin
            o_frontend_command_valid_bc3 = 1;
        end
    end
end

always_comb
begin : O_FRONTEND_COMMAND
    if(!i_rst_n)
    begin
        o_frontend_command_bc0.op_type = OP_WRITE;
        o_frontend_command_bc0.data_type = DATA_TYPE_WEIGHTS;
        o_frontend_command_bc0.row_addr = 0;
        o_frontend_command_bc0.col_addr = 0;

        o_frontend_command_bc1.op_type = OP_WRITE;
        o_frontend_command_bc1.data_type = DATA_TYPE_WEIGHTS;
        o_frontend_command_bc1.row_addr = 0;
        o_frontend_command_bc1.col_addr = 0;

        o_frontend_command_bc2.op_type = OP_WRITE;
        o_frontend_command_bc2.data_type = DATA_TYPE_WEIGHTS;
        o_frontend_command_bc2.row_addr = 0;
        o_frontend_command_bc2.col_addr = 0;

        o_frontend_command_bc3.op_type = OP_WRITE;
        o_frontend_command_bc3.data_type = DATA_TYPE_WEIGHTS;
        o_frontend_command_bc3.row_addr = 0;
        o_frontend_command_bc3.col_addr = 0;
    end
    else
    begin
        // o_frontend_command_bc0.op_type = request_fifo_out.op_type;
        // o_frontend_command_bc0.data_type = request_fifo_out.data_type;
        // o_frontend_command_bc0.row_addr = request_fifo_out.row_addr;
        // o_frontend_command_bc0.col_addr = request_fifo_out.col_addr;
//
        // o_frontend_command_bc1.op_type = request_fifo_out.op_type;
        // o_frontend_command_bc1.data_type = request_fifo_out.data_type;
        // o_frontend_command_bc1.row_addr = request_fifo_out.row_addr;
        // o_frontend_command_bc1.col_addr = request_fifo_out.col_addr;
//
        // o_frontend_command_bc2.op_type = request_fifo_out.op_type;
        // o_frontend_command_bc2.data_type = request_fifo_out.data_type;
        // o_frontend_command_bc2.row_addr = request_fifo_out.row_addr;
        // o_frontend_command_bc2.col_addr = request_fifo_out.col_addr;
//
        // o_frontend_command_bc3.op_type = request_fifo_out.op_type;
        // o_frontend_command_bc3.data_type = request_fifo_out.data_type;
        // o_frontend_command_bc3.row_addr = request_fifo_out.row_addr;
        // o_frontend_command_bc3.col_addr = request_fifo_out.col_addr;
        o_frontend_command_bc0.op_type = command.op_type;
        o_frontend_command_bc0.data_type = command.data_type;
        o_frontend_command_bc0.row_addr = command.addr[21:6];
        o_frontend_command_bc0.col_addr = command.addr[5:2];

        o_frontend_command_bc1.op_type = command.op_type;
        o_frontend_command_bc1.data_type = command.data_type;
        o_frontend_command_bc1.row_addr = command.addr[21:6];
        o_frontend_command_bc1.col_addr = command.addr[5:2];

        o_frontend_command_bc2.op_type = command.op_type;
        o_frontend_command_bc2.data_type = command.data_type;
        o_frontend_command_bc2.row_addr = command.addr[21:6];
        o_frontend_command_bc2.col_addr = command.addr[5:2];

        o_frontend_command_bc3.op_type = command.op_type;
        o_frontend_command_bc3.data_type = command.data_type;
        o_frontend_command_bc3.row_addr = command.addr[21:6];
        o_frontend_command_bc3.col_addr = command.addr[5:2];
    end
end

always_comb
begin : O_FRONTEND_WRITE_DATA
    if(!i_rst_n)
    begin
        o_frontend_write_data_bc0 = 0;
        o_frontend_write_data_bc1 = 0;
        o_frontend_write_data_bc2 = 0;
        o_frontend_write_data_bc3 = 0;
    end
    else
    begin
        // o_frontend_write_data_bc0 = write_data_fifo_out;
        // o_frontend_write_data_bc1 = write_data_fifo_out;
        // o_frontend_write_data_bc2 = write_data_fifo_out;
        // o_frontend_write_data_bc3 = write_data_fifo_out;
        o_frontend_write_data_bc0 = write_data;
        o_frontend_write_data_bc1 = write_data;
        o_frontend_write_data_bc2 = write_data;
        o_frontend_write_data_bc3 = write_data;
    end
end


//------------------------------------------//
//          Returned Data Channel           //
//------------------------------------------//
assign hs_returned_data_channel_0 = i_returned_data_valid_bc0 && o_backend_controller_ren_bc0;
assign hs_returned_data_channel_1 = i_returned_data_valid_bc1 && o_backend_controller_ren_bc1;
assign hs_returned_data_channel_2 = i_returned_data_valid_bc2 && o_backend_controller_ren_bc2;
assign hs_returned_data_channel_3 = i_returned_data_valid_bc3 && o_backend_controller_ren_bc3;
assign returned_data_transaction = (hs_returned_data_channel_0 || hs_returned_data_channel_1 || hs_returned_data_channel_2 || hs_returned_data_channel_3);

// read order fifo
DW_fifo_s1_sf #(bank_addr_width, read_order_fifo_depth, ae_level, af_level, err_mode, rst_mode)
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

assign read_order_fifo_in = command.addr[1:0];

always_comb
begin : READ_ORDER_FIFO_WR_EN
    read_order_wr_en = 0;
    if(command.op_type == OP_READ)
    begin
        read_order_wr_en = command_transaction;
    end
end

always_comb
begin : READ_ORDER_FIFO_RD_EN
    read_order_rd_en = 0;

    if(returned_data_transaction)
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

//------------------------------------------//
//             Read Data Channel            //
//------------------------------------------//
always_comb
begin : O_READ_DATA_VALID
    if(!i_rst_n)
    begin
        o_read_data_valid = 0;
    end
    else
    begin
        o_read_data_valid = (hs_returned_data_channel_0 || hs_returned_data_channel_1 || hs_returned_data_channel_2 || hs_returned_data_channel_3);
    end
end

always_comb
begin : O_READ_DATA
    if(!i_rst_n)
    begin
        o_read_data = 0;
    end
    else if(hs_returned_data_channel_0)
    begin
        o_read_data = i_returned_data_bc0;
    end
    else if(hs_returned_data_channel_1)
    begin
        o_read_data = i_returned_data_bc1;
    end
    else if(hs_returned_data_channel_2)
    begin
        o_read_data = i_returned_data_bc2;
    end
    else if(hs_returned_data_channel_3)
    begin
        o_read_data = i_returned_data_bc3;
    end
    else
    begin
        o_read_data = 0;
    end
end



endmodule