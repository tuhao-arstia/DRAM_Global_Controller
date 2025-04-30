module write_request_fifo
                 (
                 clk, rst_n,
                 push_req_n, pop_req_n,
                 data_in,
                 raw_flag,
                 empty,
                 full,
                 error,
                 data_out,
                 write_flush_flag
                 );

parameter command_width = `OP_BITS+`DATA_TYPE_BITS+`ROW_BITS+`COL_BITS+`BANK_BITS;
parameter fifo_depth = 8;
parameter ae_level = 1;
parameter af_level = 2; // write flush watermark
parameter err_mode = 0;
parameter rst_mode = 0;

input logic clk;
input logic rst_n;
input logic push_req_n;
input logic pop_req_n;
input frontend_command_t data_in;
input logic raw_flag;
output logic empty;
output logic full;
output logic error;
output frontend_command_t data_out;
output logic write_flush_flag;

logic n_write_flush_flag;

logic almost_full;

DW_fifo_s1_sf #(command_width, fifo_depth, ae_level, af_level, err_mode, rst_mode)
write_request_fifo (
    .clk(clk),
    .rst_n(rst_n),
    .push_req_n(~push_req_n),
    .pop_req_n(~pop_req_n),
    .diag_n(1'b1),
    .data_in(data_in),
    .empty(empty),
    .almost_empty(),
    .half_full(),
    .almost_full(almost_full),
    .full(full),
    .error(error),
    .data_out(data_out)
);

always_ff @(posedge clk or negedge rst_n) 
begin: WRITE_FLUSH_FLAG
    if(!rst_n) begin
        write_flush_flag <= 0;
    end
    else begin
        write_flush_flag <= n_write_flush_flag;
    end
end


always_comb begin
    if( write_flush_flag )begin
        if( empty ) begin
            n_write_flush_flag = 0;
        end
        else begin
            n_write_flush_flag = 1;
        end
    end
    else begin
        if( raw_flag || almost_full ) begin
            n_write_flush_flag = 1;
        end
        else begin
            n_write_flush_flag = 0;
        end
    end
end

endmodule