`include "define.sv"
`include "userType_pkg.sv"

import frontend_command_definition_pkg::*;

module request_fifo
                 #(parameter DATA_WIDTH = `BANK_ADDR_BITS + `ROW_ADDR_BITS + `COL_ADDR_BITS + 2,
                   parameter FIFO_DEPTH = 4,
                   // 2^4 depth
                   parameter FLUSH_WATERMARK = 12
                   // WATERMARK maximum is 2^FIFO_DEPTH - 1
                 ) 
                 (
                 i_clk, i_rst_n, i_data, i_raw_flag,
                 wr_en,
                 rd_en, 
                 o_data, o_full, o_empty,
                 o_write_flush
                 );

input logic i_clk;
input logic i_rst_n;
input frontend_command_t i_data;
input logic i_raw_flag;
input logic wr_en;
input logic rd_en;
output frontend_command_t o_data;
output logic o_full, o_empty;
output logic o_write_flush;

frontend_command_t mem [0:(1 << FIFO_DEPTH)-1];

logic [FIFO_DEPTH : 0] rd_ptr, wr_ptr;
logic [FIFO_DEPTH : 0] n_rd_ptr, n_wr_ptr;

logic n_o_empty, n_o_full;
logic n_o_write_flush;

logic [FIFO_DEPTH-1 : 0] write_flush_num;
logic [FIFO_DEPTH-1 : 0] n_write_flush_num;

logic [FIFO_DEPTH-1 : 0] n_occupied_space;

logic rd_req, wr_req;

integer i;

assign rd_req = rd_en && !o_empty;
assign wr_req = wr_en && !o_full;

always_ff @(posedge i_clk or negedge i_rst_n) begin: REQUEST_FIFO_STATUS
    if(!i_rst_n) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        o_empty <= 1;
        o_full <= 0;
        o_write_flush <= 0;
        write_flush_num <= 0;
    end
    else begin
        wr_ptr <= n_wr_ptr;
        rd_ptr <= n_rd_ptr;
        o_empty <= n_o_empty;
        o_full <= n_o_full;
        o_write_flush <= n_o_write_flush;
        write_flush_num <= n_write_flush_num;
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
    if( o_write_flush )begin
        if( !i_raw_flag && write_flush_num == 0 ) begin
            n_o_write_flush = 0;
        end
        else begin
            n_o_write_flush = 1;
        end
    end
    else begin
        if( i_raw_flag || n_occupied_space == FLUSH_WATERMARK ) begin
            n_o_write_flush = 1;
        end
        else begin
            n_o_write_flush = 0;
        end
    end
end

// write flush number setting
always_comb begin
    if( i_raw_flag || n_occupied_space == FLUSH_WATERMARK ) begin
        n_write_flush_num = n_occupied_space - rd_req;
    end
    else begin
        if( rd_req ) begin
            n_write_flush_num = write_flush_num - 1;
        end
        else begin
            n_write_flush_num = write_flush_num;
        end
    end
end 

// occupied space setting
always_comb begin
    n_occupied_space = n_wr_ptr - n_rd_ptr;
end

// fifo setting
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

always_ff @( posedge i_clk or negedge i_rst_n ) begin: REQUEST_FIFO
    if( !i_rst_n ) 
    begin
        for( i = 0; i < (1 << FIFO_DEPTH); i = i + 1 ) begin
            mem[i] <= 0;
        end
    end 
    else begin
        if( wr_req ) 
        begin
            mem[wr_ptr[FIFO_DEPTH-1:0]] <= i_data;
        end
    end
end

assign o_data = mem[rd_ptr[FIFO_DEPTH-1:0]];

  /*
  * ASSERTIONS Synchronous FIFO
  */

  // Reset startup check //
  // need this at the very begining of the simulation //
  property async_rst_startup;
	  @(posedge i_clk) !i_rst_n |-> ##1 (wr_ptr==0 && rd_ptr == 0 && o_empty);
  endproperty
  assert property (async_rst_startup)
	  else $display("rst assertion failed at strup", $time);

  // rst check in general
  property async_rst_chk;
	  @(negedge i_rst_n) 1'b1 |-> ##1 @(posedge i_clk) (wr_ptr==0 && rd_ptr == 0 && o_empty);
  endproperty
  assert property (async_rst_chk)
		else $display("rst assertion failed: ", $time);
// 1) check if data written to a location is the same data read when read ptr reaches the location
// This is a really great way to test fifo and should be used for any memory based design
// it's more involved to write such an assertion but great way to use systemverilog features

  sequence rd_detect(ptr);
    ##[0:$] (rd_en && !o_empty && (rd_ptr == ptr));
  endsequence

  property data_wr_rd_chk(wrPtr);
    // local variable
    integer ptr, data;
    @(posedge i_clk) disable iff(!i_rst_n)
    (wr_en && !o_full, ptr = wrPtr, data = i_data, $display($time, " wr_ptr=%h, i_fifo=%h",wr_ptr, i_data))
	  |-> ##1 first_match(rd_detect(ptr), $display($time, " rd_ptr=%h, o_fifo=%h",rd_ptr, o_data)) ##0  o_data == data;
  endproperty

  assert property(data_wr_rd_chk(wr_ptr))
    else $display("time data chk: ", $time);

  // 2) Don't write to fifo if full: one of the two golden rule in fifo design //

  property dont_write_if_full;
    // @(posedge i_clk) disable iff(!i_rst_n) o_full |-> ##1 $stable(wr_ptr);
    // alternative way of writing the same assertion
	  @(posedge i_clk) disable iff(!i_rst_n) wr_en && o_full |-> ##1 wr_ptr == $past(wr_ptr);
  endproperty

  assert property (dont_write_if_full)
    else $display("failed at time p2: ", $time);

    // 3) don't read when empty: second golden rule
    property dont_read_if_empty;
	    @(posedge i_clk) disable iff(!i_rst_n) rd_en && o_empty |-> ##1 $stable(rd_ptr);
    endproperty

    assert property (dont_read_if_empty)
      else $display("failed at time p3: ", $time);

     // 4) rd/wr ptr should only increment by 1 on rd/wr req
     property inc_wr_one;
      @(posedge i_clk) disable iff(!i_rst_n) wr_en && !o_full |-> ##1 (wr_ptr-1'b1 == $past(wr_ptr));
     endproperty

     assert property (inc_wr_one)
       else $display("time p4: ", $time);

      // 5) rd/wr ptr should onlu increment by 1 on rd/wr req
      property inc_rd_ptr;
        @(posedge i_clk) disable iff(!i_rst_n) rd_en && !o_empty |-> ##1 (rd_ptr - 1'b1 == $past(rd_ptr));
      endproperty

     assert property (inc_rd_ptr)
       else $display("time p5: ", $time);

endmodule