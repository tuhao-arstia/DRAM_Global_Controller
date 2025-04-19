////////////////////////////////////////////////////////////////////////
// Project Name: 
// Task Name   : DRAM Global Controller
// Module Name : Global_Controller
// File Name   : Global_Controller.sv
////////////////////////////////////////////////////////////////////////

`include "write_addr_fifo.sv"
`include "write_request_fifo.sv"

module Global_Controller#(
                            parameter GLOBAL_CONTROLLER_WORD_SIZE = 1024
)(
                          i_clk,
                          i_rst_n,
                          
                          // request channel
                          i_command_valid,
                          i_command,
                          i_write_data,
                          o_controller_ready,

                          // read data channel
                          o_read_data_valid;
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
// TO BE CORRECTED: 
// 1 for valid bit
parameter raw_addr_width = 1+`ROW_BITS+`COL_BITS;
//
parameter bank_addr_width = `BANK_BITS;
parameter fifo_depth = 8;
parameter ae_level = 1;
parameter af_level = 1;
parameter af_level_write_request = 4; // 12 write requests
parameter err_mode = 0;
parameter rst_mode = 0;
integer i;

// transaction signals
// handshake signals
logic hs_request_channel;

logic hs_returned_data_channel;//0123?

// REQUEST CHANNEL
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

// write data fifo 
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] write_data_fifo_out;
logic write_data_fifo_full, write_data_fifo_empty;
logic write_data_fifo_error;

// write address fifo (RAW related)
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS-1:0] write_addr;
logic write_addr_fifo_full, write_addr_fifo_empty;
// raw_info = {valid_bit, addr}
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS:0] raw_info [0:7];
logic raw_valid [0:7];
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS-1:0] raw_addr [0:7];
logic [`ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS-1:0] raw_current_addr;
logic raw_flag;

// request scheduling
logic delayed_backend_controller_ready_bc0, delayed_backend_controller_ready_bc1;
logic delayed_backend_controller_ready_bc2, delayed_backend_controller_ready_bc3;
logic delayed_read_request_fifo_empty, delayed_write_request_fifo_empty;
backend_command_t scheduled_command;
logic [`BANK_BITS-1:0] scheduled_bank_addr;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] scheduled_write_data;

// read back
logic [`BACKEND_WORD_SIZE-1:0] returned_data;


//----------------------------------------------------//
//              Global Controller DESIGN              //
//----------------------------------------------------//
//---------------------------------------//
//            Request Channel            //
//---------------------------------------//
assign hs_request_channel = i_interconnection_request_valid && o_scheduler_ready;

always_ff @(posedge i_clk or negedge i_rst_n) 
begin: I_COMMAND
    if(!i_rst_n) 
    begin
        command <= 0;
    end
    else if (hs_request_channel)
    begin
        command <= i_command;
    end
    else
    begin
        command <= 0;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n)
begin: I_WRITE_DATA
    if(!i_rst_n)
    begin
        write_data <= 0;
    end
    else if(hs_request_channel && i_command.op_type == OP_WRITE)
    begin
        write_data <= i_write_data;
    end
    else
    begin
        write_data <= 0;
    end
end

// o_scheduler_ready
// check this one later
assign o_scheduler_ready = !read_request_fifo_full && !write_request_fifo_full && !write_flush;

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

assign read_request_wr_en = (command.op_type == 1'b1);

// change to sequential logic if needed
always_comb
begin : READ_REQUEST_FIFO_RD_EN
    if( i_backend_controller_ready )
    begin
        if( !write_flush || write_request_fifo_empty )
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
write_request_fifo write_request_fifo (
    .clk(i_clk),
    .rst_n(i_rst_n),
    .push_req_n(~write_request_wr_en),
    .pop_req_n(~write_request_rd_en),
    .data_in(command),
    .raw_flag(raw_flag),
    .empty(write_request_fifo_empty),
    .full(write_request_fifo_full),
    .error(read_request_fifo_error),
    .data_out(write_request_candidate),
    .write_flush_flag(write_flush)
);

assign write_request_wr_en = interconnection_write_data_last;

// regarding empty: inside the fifo file
always_comb
begin : WRITE_REQUEST_FIFO_RD_EN
    if(i_backend_controller_ready)
    begin
        if(read_request_fifo_empty || write_flush)
        begin
            // in write flush mode: keep reading write request fifo until empty
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
// write_data_fifo #(.DATA_WIDTH(`BACKEND_WORD_SIZE), .FIFO_DEPTH(4)) write_data_fifo (
    // .i_clk(i_clk),
    // .i_rst_n(i_rst_n),
    // .i_data(write_data_fifo_in),
    // .wr_en(write_request_wr_en),
    // .rd_en(write_request_rd_en),
    // .o_data(write_data_fifo_out),
    // .o_full(write_data_fifo_full),
    // .o_empty(write_data_fifo_empty)
// );

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

// request scheduling
// delayed ready
always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : DELAYED_BACKEND_CONTROLLER_READY
    if(!i_rst_n) 
    begin
        delayed_backend_controller_ready_bc0 <= 0;
        delayed_backend_controller_ready_bc1 <= 0;
        delayed_backend_controller_ready_bc2 <= 0;
        delayed_backend_controller_ready_bc3 <= 0;
    end
    else
    begin
        delayed_backend_controller_ready_bc0 <= i_backend_controller_ready_bc0;
        delayed_backend_controller_ready_bc1 <= i_backend_controller_ready_bc1;
        delayed_backend_controller_ready_bc2 <= i_backend_controller_ready_bc2;
        delayed_backend_controller_ready_bc3 <= i_backend_controller_ready_bc3;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : SCHEDULED_COMMAND
    if(!i_rst_n) 
    begin
        scheduled_command.op_type <= 0;
        scheduled_command.data_type <= 0;
        scheduled_command.row_addr <= 0;
        scheduled_command.col_addr <= 0;
    end
    else if((write_flush && !write_request_fifo_empty) || read_request_fifo_empty)
    begin
        scheduled_command.op_type <= write_request_candidate.op_type;
        scheduled_command.data_type <= write_request_candidate.data_type;
        scheduled_command.row_addr <= write_request_candidate.row_addr;
        scheduled_command.col_addr <= write_request_candidate.col_addr;
    end
    else
    begin
        scheduled_command.op_type <= read_request_candidate.op_type;
        scheduled_command.data_type <= read_request_candidate.data_type;
        scheduled_command.row_addr <= read_request_candidate.row_addr;
        scheduled_command.col_addr <= read_request_candidate.col_addr;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : SCHEDULED_BANK_ADDR
    if(!i_rst_n) 
    begin
        scheduled_bank_addr <= 0;
    end
    else if((write_flush && !write_request_fifo_empty) || read_request_fifo_empty)
    begin
        scheduled_bank_addr <= write_request_candidate.bank_addr;
    end
    else
    begin
        scheduled_bank_addr <= read_request_candidate.bank_addr;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : SCHEDULED_WRITE_DATA
    if(!i_rst_n) 
    begin
        scheduled_write_data <= 0;
    end
    else
    begin
        scheduled_write_data <= write_data_fifo_out;
    end
    // else if((write_flush && !write_request_fifo_empty) || read_request_fifo_empty)
    // begin
        // scheduled_write_data <= write_data_fifo_out;
    // end
    // else
    // begin
        // scheduled_write_data <= 0;
    // end
end



// command channels output logics
// delayed request fifo empty
always_ff @(posedge i_clk or negedge i_rst_n) 
begin : DELAYED_READ_REQUEST_FIFO_EMPTY
    if (!i_rst_n) 
    begin
        delayed_read_request_fifo_empty <= 1;
    end
    else 
    begin
        delayed_read_request_fifo_empty <= read_request_fifo_empty;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) 
begin : DELAYED_WRITE_REQUEST_FIFO_EMPTY
    if (!i_rst_n) 
    begin
        delayed_write_request_fifo_empty <= 1;
    end
    else 
    begin
        delayed_write_request_fifo_empty <= write_request_fifo_empty;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : O_FRONTEND_COMMAND_VALID_BC0
    if(!i_rst_n) 
    begin
        o_frontend_command_valid_bc0 <= 0;
    end
    else if(delayed_backend_controller_ready_bc0 && scheduled_bank_addr == 2'b00)
    // use delayed ready to set the command valid
    begin
        if(!delayed_read_request_fifo_empty || !delayed_write_request_fifo_empty)
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
    else if(delayed_backend_controller_ready_bc1 && scheduled_bank_addr == 2'b01)
    begin
        if(!delayed_read_request_fifo_empty || !delayed_write_request_fifo_empty)
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
    else if(delayed_backend_controller_ready_bc2 && scheduled_bank_addr == 2'b10)
    begin
        if(!delayed_read_request_fifo_empty || !delayed_write_request_fifo_empty)
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
    else if(delayed_backend_controller_ready_bc3 && scheduled_bank_addr == 2'b11)
    begin
        if(!delayed_read_request_fifo_empty || !delayed_write_request_fifo_empty)
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
        o_frontend_command_bc0 <= 0;
        o_frontend_command_bc1 <= 0;
        o_frontend_command_bc2 <= 0;
        o_frontend_command_bc3 <= 0;
    end
    else
    begin
        o_frontend_command_bc0 <= scheduled_command;
        o_frontend_command_bc1 <= scheduled_command;
        o_frontend_command_bc2 <= scheduled_command;
        o_frontend_command_bc3 <= scheduled_command;
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
        o_frontend_write_data_bc0 <= scheduled_write_data;
        o_frontend_write_data_bc1 <= scheduled_write_data;
        o_frontend_write_data_bc2 <= scheduled_write_data;
        o_frontend_write_data_bc3 <= scheduled_write_data;
    end
end


//------------------------------------------//
//          Returned Data Channel           //
//------------------------------------------//
assign hs_backend_controller_to_frontend_scheduler = i_returned_data_valid && o_frontend_receive_ready;

always_ff @(posedge i_clk or negedge i_rst_n)
begin: O_FRONTEND_RECEIVE_READY
    if(!i_rst_n) 
    begin
        o_frontend_receive_ready <= 0;
    end
    else if(!o_stall_backend_controller)
    begin
        o_frontend_receive_ready <= 1;
    end
    else
    begin
        o_frontend_receive_ready <= 0;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n)
begin: RETURNED_DATA
    if(!i_rst_n) 
    begin
        returned_data <= 0;
    end
    else if(hs_returned_data_channel)
    begin
        returned_data <= i_returned_data;
    end
end

//------------------------------------------//
//             Read Data Channel            //
//------------------------------------------//
assign hs_frontend_scheduler_to_interconnection = i_interconnection_ready && o_scheduler_request_valid;

read_data_fifo #(.DATA_WIDTH(`BACKEND_WORD_SIZE), .FIFO_DEPTH(4), .STALL_WATERMARK(3)) read_data_fifo (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data(returned_data),
    .wr_en(read_data_fifo_wr_en),
    .rd_en(read_info_rd_en),
    .o_data(read_data_fifo_out),
    .o_full(read_data_fifo_full),
    .o_empty(read_data_fifo_empty),
    .o_stall(read_data_fifo_stall)
);

assign read_data_fifo_wr_en = hs_backend_controller_to_frontend_scheduler;
assign read_data_fifo_rd_en = (read_data_counter == 3);

// counter to help output read data
always_ff @(posedge i_clk or negedge i_rst_n)
begin : READ_DATA_COUNTER
    if(!i_rst_n) 
    begin
        read_data_counter <= 0;
    end
    else
    begin
        read_data_counter <= n_read_data_counter;
    end    
end
always_comb
begin : N_READ_DATA_COUNTER
    if(i_interconnection_ready && !read_data_fifo_empty)
    begin
        n_read_data_counter = read_data_counter + 1;
    end
    else
    begin
        n_read_data_counter = read_data_counter;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : O_SCHEDULER_REQUEST_VALID
    if(!i_rst_n) 
    begin
        o_scheduler_request_valid <= 0;
    end
    else if(i_interconnection_ready && !read_data_fifo_empty)
    begin
        o_scheduler_request_valid <= 1;
    end
    else
    begin
        o_scheduler_request_valid <= 0;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n )
begin : O_SCHEDULER_READ_DATA
    if(!i_rst_n) 
    begin
        o_scheduler_read_data <= 0;
    end
    else
    begin
        o_scheduler_read_data <= n_o_scheduler_read_data;
    end
end
always_comb
begin : N_O_SCHEDULER_READ_DATA
    case (read_data_counter)
        0:begin
            n_o_scheduler_read_data = read_data_fifo_out[1023:768];
        end 
        1:begin
            n_o_scheduler_read_data = read_data_fifo_out[767:512];
        end
        2:begin
            n_o_scheduler_read_data = read_data_fifo_out[511:256];
        end
        3:begin
            n_o_scheduler_read_data = read_data_fifo_out[255:0];
        end
        default:begin
            n_o_scheduler_read_data = read_data_fifo_out[1023:768];
        end
    endcase
end


endmodule

