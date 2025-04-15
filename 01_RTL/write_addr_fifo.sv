// `include "define.sv"
// `include "userType_pkg.sv"
// `include "../00_TESTBED/define.sv"

// import frontend_command_definition_pkg::*;

module write_addr_fifo
                        #(parameter DATA_WIDTH = `ROW_ADDR_BITS+`COL_ADDR_BITS+`BANK_ADDR_BITS,
                          parameter FIFO_DEPTH = 4
                          // 2^4 depth
                        ) 
                        (
                        i_clk, i_rst_n, i_data,
                        wr_en, rd_en, 
                        o_addr_0, o_addr_1, o_addr_2, o_addr_3, o_addr_4, o_addr_5, o_addr_6, o_addr_7,
                        o_full, o_empty
                        );

input logic i_clk;
input logic i_rst_n;
// i_data = {bank_addr, row_addr, col_addr}
input logic [DATA_WIDTH-1 : 0] i_data;
input logic wr_en;
input logic rd_en;
output logic [DATA_WIDTH : 0] o_addr_0, o_addr_1, o_addr_2, o_addr_3, o_addr_4, o_addr_5, o_addr_6, o_addr_7;
output logic o_full, o_empty;

// address fifo needs one more valid bit for output address
logic [DATA_WIDTH : 0] mem [0:(1 << FIFO_DEPTH)-1];
logic [FIFO_DEPTH : 0] rd_ptr, wr_ptr;
logic [FIFO_DEPTH : 0] n_rd_ptr, n_wr_ptr;
logic [FIFO_DEPTH-1 : 0] o_ptr;
logic [FIFO_DEPTH-1 : 0] o_ptr_0, o_ptr_1, o_ptr_2, o_ptr_3, o_ptr_4, o_ptr_5, o_ptr_6, o_ptr_7;
logic n_o_empty, n_o_full;

logic rd_req, wr_req;

integer i;

assign rd_req = rd_en && !o_empty;
assign wr_req = wr_en && !o_full;

always_ff @(posedge i_clk or negedge i_rst_n) begin: WRITE_ADDR_FIFO_STATUS
    if(!i_rst_n) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        o_empty <= 1;
        o_full <= 0;
    end
    else begin
        wr_ptr <= n_wr_ptr;
        rd_ptr <= n_rd_ptr;
        o_empty <= n_o_empty;
        o_full <= n_o_full;
    end
end

always_comb begin
    if(n_wr_ptr == n_rd_ptr) begin
        n_o_empty = 1;
    end
    else begin
        n_o_empty = 0;
    end
end

always_comb begin
    if(n_wr_ptr == {~n_rd_ptr[FIFO_DEPTH], n_rd_ptr[FIFO_DEPTH-1:0]}) begin
        n_o_full = 1;
    end
    else begin
        n_o_full = 0;
    end
end

always_comb begin
    if( wr_req ) begin
        n_wr_ptr = wr_ptr + 1;
    end
    else begin
        n_wr_ptr = wr_ptr;
    end
end

always_comb begin
    if( rd_req ) begin
        n_rd_ptr = rd_ptr + 1;
    end
    else begin
        n_rd_ptr = rd_ptr;
    end
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin: WRITE_ADDR_FIFO
    if( !i_rst_n ) begin
        for( i = 0; i < (1 << FIFO_DEPTH); i = i + 1 ) begin
            mem[i] <= 0;
        end
    end 
    else begin
        if( wr_req ) begin
            mem[wr_ptr[FIFO_DEPTH-1:0]] <= {1'b1, i_data};
        end
        else if ( rd_req ) begin
            // reset the valid bit when read
            mem[rd_ptr[FIFO_DEPTH-1:0]] <= 0;
        end
    end
end

// o_addr_0 is the oldest data
assign o_ptr = wr_ptr[FIFO_DEPTH-1:0];
assign o_ptr_0 = o_ptr - 4'd7;
assign o_ptr_1 = o_ptr - 4'd6;
assign o_ptr_2 = o_ptr - 4'd5;
assign o_ptr_3 = o_ptr - 4'd4;
assign o_ptr_4 = o_ptr - 4'd3;
assign o_ptr_5 = o_ptr - 4'd2;
assign o_ptr_6 = o_ptr - 4'd1;
assign o_ptr_7 = o_ptr;

assign o_addr_0 = mem[o_ptr_0];
assign o_addr_1 = mem[o_ptr_1];
assign o_addr_2 = mem[o_ptr_2];
assign o_addr_3 = mem[o_ptr_3];
assign o_addr_4 = mem[o_ptr_4];
assign o_addr_5 = mem[o_ptr_5];
assign o_addr_6 = mem[o_ptr_6];
assign o_addr_7 = mem[o_ptr_7];

endmodule