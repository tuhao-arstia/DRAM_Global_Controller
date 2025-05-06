////////////////////////////////////////////////////////////////////////
// Project Name: eHome-IV
// Task Name   : Command Scheduler
// Module Name : cmd_generator
// File Name   : cmd_generator.v
// Description : schedule issue commands
// Author      : Chih-Yuan Chang
// Revision History:
// Date        : 2012.12.12
////////////////////////////////////////////////////////////////////////

`define B_COUNTER_WIDTH 8
`include "Usertype.sv"
`include "define.sv"

module cmd_generator(
                         clk,
                         rst_n,
                         isu_fifo_full,
                         ba0_info,
                         ba0_stall,
                         sch_out, // The command, addr, bank
                         sch_issue
                         );

import usertype::*;

input clk;
input rst_n;
input isu_fifo_full;
input [`BA_INFO_WIDTH-1:0]ba0_info;

output ba0_stall;

output [`ISU_FIFO_WIDTH-1:0]sch_out ;
output sch_issue ;


reg ba0_stall;


sch_cmd_t sch_command ;
reg [`ADDR_BITS-1:0]sch_addr;
reg [`BA_BITS-1:0]sch_bank;

reg sch_issue ;

reg [2:0]act_count ;
reg [2:0]write_count ;
reg [2:0]read_count ;
reg [2:0]pre_count ;

bank_state_t bax_state;
bank_state_t f_ba_state;

bank_state_t ba0_state ;

bank_info_t ba0_info_in;

always_comb begin :BANKS_INFO_IN
  ba0_info_in = ba0_info;
end

always_comb begin :BANKS_STATE
  ba0_state = ba0_info_in.bank_state;
end


reg act_pri;
reg read_pri;
reg write_pri;
reg pre_pri;
r_w_t current_rw ;

wire [`B_COUNTER_WIDTH-1:0]b0_counter;


reg [`B_COUNTER_WIDTH-1:0] b0_c_counter;


wire pre0_threshold = (b0_counter > $unsigned(16)) ? 1'b1 : 1'b0 ;

bx_counter     b0(.ba_state  (ba0_state),
                  .clk       (clk),
                  .rst_n     (rst_n),
                  .b_counter (b0_counter) );


// According to the states of each banks
// To check if there is a commands needed for issue in each bank, if there is a command, the signal will be high
wire have_cmd_act ;
wire have_cmd_read ;
wire have_cmd_write ;
wire have_cmd_pre ;

check_or_state    check_cmd_act(ba0_state,`B_ACTIVE,have_cmd_act);
check_or_state    check_cmd_write(ba0_state,`B_WRITE,have_cmd_write);
check_or_state    check_cmd_read(ba0_state,`B_READ,have_cmd_read);
check_or_state    check_cmd_pre(ba0_state,`B_PRE,have_cmd_pre);

// act count counts to 4
always@(posedge clk)
begin
if(rst_n==0)
  act_count <= 0 ;
else
  if(have_cmd_act)
     act_count <= (act_count==4)? 1 : act_count + 1 ;
  else
     act_count <= act_count ;
end

always@(posedge clk) begin
if(rst_n==0)
  read_count <= 0 ;
else
  if(have_cmd_read)
     read_count <= (read_count==4)? 1 : read_count + 1 ;
  else if(have_cmd_write)
     read_count <= 0 ;
  else
     read_count <=  read_count ;
end

always@(posedge clk or negedge rst_n) begin // Counts to 4, since burst length is of 4
if(~rst_n)
  write_count <= 0 ;
else
  if(have_cmd_write)
     write_count <= (write_count==4)? 1 : write_count + 1 ;
  else if(have_cmd_read)
     write_count <= 0 ;
  else
     write_count <= write_count ;
end

always@(posedge clk or negedge rst_n) begin // Counts to 3
if(~rst_n)
    pre_count <= 0 ;
else
  if(have_cmd_pre)
     pre_count <= (pre_count==3)? 1 : pre_count + 1 ;
  else
     pre_count <= pre_count ;
end


always_comb begin: SCH_ADDR_ISSUE_BLOCK
if(ba0_state == B_ACTIVE || ba0_state == B_READ || ba0_state == B_WRITE || ba0_state == B_PRE || ba0_state == B_REFRESH_CHECK||ba0_state == B_PREA)
  if(isu_fifo_full == 1'b0)
    {f_ba_state,sch_addr,sch_bank,sch_issue} = {ba0_info_in.bank_state,ba0_info_in.addr,3'd0,1'b1} ;
  else
    {f_ba_state,sch_addr,sch_bank,sch_issue} = {ba0_info_in.bank_state,ba0_info_in.addr,3'd0,1'b0} ;
else
  {f_ba_state,sch_addr,sch_bank,sch_issue} = {ba0_info_in.bank_state,ba0_info_in.addr,3'd0,1'b0} ;
end

always_comb begin
if(write_count != 0 && read_count == 0)
  current_rw = WRITE ; //continuous write
else if(write_count == 0 && read_count != 0)
  current_rw = READ ; //continuous read
else
  current_rw = WRITE ;
end

always_comb begin: SCH_BA_CMD_DECODER
sch_command = ATCMD_NOP ;
case(f_ba_state)
  B_ACTIVE : sch_command = ATCMD_ACTIVE ;
  B_READ   : sch_command = ATCMD_READ ;
  B_WRITE  : sch_command = ATCMD_WRITE ;
  B_PRE    : sch_command = ATCMD_PRECHARGE ;
  //refresh PRE
  B_PREA   : sch_command = ATCMD_PREA ;
  // Add auto-precharge commands
  B_READA  : sch_command = ATCMD_RDA ;
  B_WRITEA : sch_command = ATCMD_WRA ;
  B_REFRESH_CHECK: sch_command = ATCMD_REFRESH ;
  default   : sch_command = ATCMD_NOP ;
endcase
end

assign sch_out = {sch_command,sch_addr} ; // 3

// Why do we need stall signals? Only one bank can be granted at a time
always@* begin:STALL_GRANTER
ba0_stall = 1'b1;

if(isu_fifo_full==0)
	ba0_stall = 1'b0 ;
else
  ba0_stall = 1'b1 ;
end

endmodule

module  check_or_state(other_ba_state0,
                       state,
                       have
                       );

input [`FSM_WIDTH2-1:0]other_ba_state0;
input [`FSM_WIDTH2-1:0]state;

output have ;

// Check to see if there exists a certain state within the bank

assign have = (other_ba_state0 == state)? 1'b1 : 1'b0 ;

endmodule

// Counter in charge of timing constraints counting
module bx_counter(ba_state,
                  clk,
                  rst_n,
                  b_counter);

input [`FSM_WIDTH2-1:0] ba_state ;
input clk ;
input rst_n ;

output [`B_COUNTER_WIDTH-1:0]b_counter;

bank_state_t ba_state_i;

always_comb begin
  // typecast the state to the bank_state_t
  ba_state_i = bank_state_t'(ba_state) ;
end

reg [`B_COUNTER_WIDTH-1:0]b_counter ;

always@(posedge clk or negedge rst_n) begin
  if(~rst_n)
    b_counter <= 0 ;
  else
    case(ba_state_i)
      B_IDLE        : b_counter <= 0 ;
      B_ACT_CHECK   : b_counter <= b_counter + 1 ;
      B_WRITE_CHECK : b_counter <= b_counter + 1 ;
      B_READ_CHECK  : b_counter <= b_counter + 1 ;
      B_PRE_CHECK   : b_counter <= b_counter + 1 ;
      B_ACTIVE      : b_counter <= b_counter + 1 ;
      B_READ,
      B_WRITE,
      B_PRE         : b_counter <= b_counter + 1 ;
      B_ACT_STANDBY : b_counter <= 0 ;
      default        : b_counter <= 0 ;
    endcase
end

endmodule

module counter_compare(compare_in,
                       compare_0,
                       compare_1,
                       compare_2,


                       big

                       );

input [`B_COUNTER_WIDTH-1:0]compare_in;
input [`B_COUNTER_WIDTH-1:0]compare_0;
input [`B_COUNTER_WIDTH-1:0]compare_1;
input [`B_COUNTER_WIDTH-1:0]compare_2;


output big ;

assign big = (compare_in > compare_0 && compare_in > compare_1 && compare_in > compare_2)  ? 1 : 0 ;

endmodule