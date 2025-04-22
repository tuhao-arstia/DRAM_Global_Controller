////////////////////////////////////////////////////////////////////////
// Project Name: 3D-DRAM Memory Controller
// Task Name   : Memory Controller
// Module Name : Ctrl
// File Name   : Ctrl.sv
// Description : External memory interface construction
// Author      : YEH SHUN-LIANG
// Revision History:
// Date        : 2025/04/01
////////////////////////////////////////////////////////////////////////

`include "bank_FSM.sv"
`include "tP_counter.sv"
`include "cmd_scheduler.sv"
`include "define.sv"
`include "Usertype.sv"
`include "DW_fifo_s1_df.v"


module Ctrl(
//== I/O from System ===============
               power_on_rst_n,
               clk,
               clk2,
//==================================

//== I/O from access command =======
               write_data,
               i_command,
               read_data,

               valid,
               ba_cmd_pm,
               read_data_valid,
              //  issue_fifo_stall,
               i_controller_ren,

//==================================
//=== I/O from DDR3 interface ======
               rst_n,
               cke,
               cs_n,
               ras_n,
               cas_n,
               we_n,
               dm_tdqs_in,
               dm_tdqs_out,
               ba,
               addr,
               data_in,
               data_out,
               data_all_in,
               data_all_out,
               dqs_in,
               dqs_out,
               dqs_n_in,
               dqs_n_out,
               tdqs_n,
               odt,
               ddr3_rw
);
import usertype::*;



    // Declare Ports

    //== I/O from System ===============
    input  power_on_rst_n;
    input  clk;
    input clk2;
    //==================================
    //== I/O from access command =======
    input  [`DQ_BITS*8-1:0]   write_data;
    output [`DQ_BITS*8-1:0]    read_data;
    input  [`MEM_CTR_COMMAND_BITS-1:0] i_command;
    input  valid ;

    output ba_cmd_pm;
    output read_data_valid;
    input i_controller_ren; // Reading the rdata buffer of backend controller
   //===================================
   //=== I/O from DDR3 interface ======
    output   reg rst_n;
    output   reg cke;
    output   reg cs_n;
    output   reg ras_n;
    output   reg cas_n;
    output   reg we_n;

    input    [`DM_BITS-1:0]   dm_tdqs_in;
    output   reg [`DM_BITS-1:0]   dm_tdqs_out;

    output   reg [`BA_BITS-1:0]   ba;
    output   reg [`ADDR_BITS-1:0] addr;

    input   [`DQ_BITS-1:0]     data_in;
    output  reg [`DQ_BITS-1:0]  data_out;

    input    [`DQ_BITS*8-1:0]     data_all_in;
    output   reg [`DQ_BITS*8-1:0] data_all_out;

    input    [`DQS_BITS-1:0]  dqs_in;
    output   reg [`DQS_BITS-1:0]  dqs_out;

    input    [`DQS_BITS-1:0]  dqs_n_in;
    output   reg [`DQS_BITS-1:0]  dqs_n_out;

    input    [`DQS_BITS-1:0]  tdqs_n;
    output   reg odt;
    output   reg ddr3_rw ;// 0: write
                      // 1: read
    //===================================
    // command for connection
    command_t command;

    logic i_controller_ren;

    always_comb begin:CMD_DECODER
      command = i_command ;
    end


main_state_t state,state_nxt ;
wire issue_fifo_stall;



d_state_t d_state,d_state_nxt ;



dq_state_t dq_state,dq_state_nxt ;

reg [9:0]init_cnt,init_cnt_next; //used for count command waiting latencys

//used for read/write waiting output latencys
reg [7:0]d0_counter,d0_counter_nxt;
reg [7:0]d1_counter,d1_counter_nxt;
reg [7:0]d2_counter,d2_counter_nxt;
reg [7:0]d3_counter,d3_counter_nxt;
reg [7:0]d4_counter,d4_counter_nxt;

reg [4:0]d_counter_used,
         d_counter_used_nxt,
         d_counter_used_start,
         d_counter_used_end ;                //[0]:d0_counter,
                                             //[1]:d1_counter,
                                             //[2]:d2_counter,
                                             //[3]:d3_counter,
                                             //[4]:d4_counter

// Timing constraints counters
reg [2:0]tCCD_counter ;
reg [3:0]tRTW_counter ;
reg [5:0]tWTR_counter ;

// Individual bank timing constraints counters
wire [4:0]tP_ba0_counter;
// These are all recoded within the bank tp_module
wire [5:0]tRAS0_counter;
wire [`ROW_BITS-1:0]tREF0_counter;
recode_state_t tP_c0_recode;

logic read_data_buf_valid;




reg [4:0]tP_ba_cnt ;
reg [5:0]tRAS_ba_cnt;

recode_state_t tP_recode_state ; // Restore this using excel

// reg [3:0]o_counter,o_counter_nxt;
reg [3:0]dq_counter,dq_counter_nxt;
reg out_ff ;
reg read_data_valid ;
reg W_BL ;

reg  [8*`DQ_BITS-1:0]  data_all_out_nxt;
// reg  [`DQ_BITS-1:0]  data_out_t;
reg  [`DM_BITS-1:0]  dm_tdqs_out_nxt;
reg  [`DQS_BITS-1:0] dqs_out_nxt;
reg [`DQS_BITS-1:0]  dqs_n_out_nxt;

reg [`BA_BITS-1:0] act_bank ;
reg [`ADDR_BITS-1:0] act_row ;
reg [`ADDR_BITS-1:0] act_addr ;
reg [`DQ_BITS*8-1:0] read_data ;
sch_cmd_t act_command ;
reg act_busy ;


reg [`DQ_BITS*8-1:0] WD ;

reg [4:0] cmd_RW_buf ; // 0 : write , 1 : read

// reg [2:0]W_buf_ptr ;
reg [2:0]process_BL ;

// reg [`DQ_BITS-1:0] RD_buf[7:0] ;
reg [8*`DQ_BITS-1:0] RD_buf_all;
// reg [`DQ_BITS-1:0] RD_temp;

// reg read_odd ;

reg [1:0]bank_state;

// reg [7:0]pre_all_t ;
// reg pre_all ;
sch_cmd_t now_issue ;
reg [2:0]now_bank;
reg [2:0]f_bank;
reg f_auto_pre ;

reg [`ADDR_BITS-1:0] now_addr ;
reg pre_store ;

sch_cmd_t pre_cmd ;
reg [2:0]pre_bank ;
reg [`ADDR_BITS-1:0] pre_addr ;

reg [15:0]MR0,MR1,MR2,MR3 ;
reg tP_all_zero ;

bank_state_t ba0_state ;


wire ba0_busy;
wire [`ADDR_BITS-1:0] ba0_addr;
wire [`DQ_BITS*8-1:0] ba0_wdata;
wire [3:0]ba0_command;
wire ba0_issue;
process_cmd_t ba0_process_cmd;
wire ba0_stall;


reg ba_cmd_pm ;

wire bank_refresh_completed;

//====== simulation test signal ======================
// wire [`DQ_BITS-1:0] RD_buf_0 = RD_buf[0] ;
// wire [`DQ_BITS-1:0] RD_buf_1 = RD_buf[1] ;
// wire [`DQ_BITS-1:0] RD_buf_2 = RD_buf[2] ;
// wire [`DQ_BITS-1:0] RD_buf_3 = RD_buf[3] ;
// wire [`DQ_BITS-1:0] RD_buf_4 = RD_buf[4] ;
// wire [`DQ_BITS-1:0] RD_buf_5 = RD_buf[5] ;
// wire [`DQ_BITS-1:0] RD_buf_6 = RD_buf[6] ;
// wire [`DQ_BITS-1:0] RD_buf_7 = RD_buf[7] ;

//=====================================================
// FIFOS Signals
//=====================================================
wire [`ISU_FIFO_WIDTH-1:0]isu_fifo_out;
wire [`ISU_FIFO_WIDTH-1:0]isu_fifo_out_pre;
wire isu_fifo_full;
wire isu_fifo_vfull;
wire isu_fifo_empty;



reg wdata_fifo_wen;
reg [`WDATA_FIFO_WIDTH-1:0]wdata_fifo_in;
reg wdata_fifo_ren;
wire [`WDATA_FIFO_WIDTH-1:0]wdata_fifo_out;
wire wdata_fifo_full;
wire wdata_fifo_vfull;
wire wdata_fifo_empty;


//DRAM Module


wire refresh_issued_f;
wire receive_command_handshake_f;


// BANKS FSM 0,1,2,3
bank_FSM    ba0(.state      (state) ,
                .stall      (ba0_stall),   // Can simply add stall during refresh?
                .valid      (valid)   ,
                .command    (command)   ,
                .number     (3'd0)   ,
                .rst_n      (power_on_rst_n)   ,
                .clk        (clk)   ,
                .ba_state   (ba0_state)    ,
                .ba_busy    (ba0_busy  )   ,
                .ba_addr    (ba0_addr    ) ,

                .ba_issue   (ba0_issue),
                .process_cmd(ba0_process_cmd),
                .bank_refresh_completed(bank_refresh_completed),
                .cmd_received_f(receive_command_handshake_f),
                .wdata_fifo_full_flag(wdata_fifo_full)
                );


wire [`BA_INFO_WIDTH-1:0]ba0_info = {ba0_state,ba0_addr,ba0_process_cmd} ;
wire [`ISU_FIFO_WIDTH-1:0] sch_out ;
wire sch_issue ;

//Command Schedular
cmd_scheduler  scheduler(
                         .clk      (clk           )  ,
                         .rst_n    (power_on_rst_n)     ,
                         .isu_fifo_full (isu_fifo_full) ,
                         .ba0_info (ba0_info)  ,
                         .ba0_stall(ba0_stall) ,
                         .sch_out  (sch_out  ) ,
                         .sch_issue(sch_issue)
                         );


//Timing Counter
tP_counter  tP_ba0(.rst_n        (power_on_rst_n),
                   .clk          (clk),
                   .f_bank       (f_bank),
                   .BL           (MR0[1:0]),
                   .refresh_flag (now_issue == ATCMD_REFRESH),
                   .state_nxt    (state_nxt),
                   .number       (3'd0),
                   .tP_ba_counter(tP_ba0_counter),
                   .tRAS_counter (tRAS0_counter),
				           .tREF_counter (tREF0_counter),
                   .recode       (tP_c0_recode),
                   .auto_pre     (f_auto_pre)
                   );

wire isu_fifo_wen = sch_issue ;
wire isu_fifo_almost_empty;
wire isu_fifo_half_full;
wire issue_fifo_error;

localparam  CTRL_FIFO_DEPTH = 6; // This is the optimal fifo depth

localparam  ISSUE_FIFO_WIDTH =  $bits(issue_fifo_cmd_in_t);
localparam  ISSUE_FIFO_DEPTH = CTRL_FIFO_DEPTH;

// issue_FIFO  isu_fifo(.clk          (clk),
//                      .rst_n        (power_on_rst_n),
//                      .wen          (isu_fifo_wen),
//                      .data_in      (sch_out),
//                      .ren          (~act_busy),
//                      .data_out     (isu_fifo_out),
//                      .data_out_pre (isu_fifo_out_pre),
//                      .full         (isu_fifo_full),
//                      .virtual_full (isu_fifo_vfull),
//                      .empty        (isu_fifo_empty)
//                      );

 DW_fifo_s1_sf_inst #(.width(ISSUE_FIFO_WIDTH),.depth(ISSUE_FIFO_DEPTH),.err_mode(2),.rst_mode(0)) isu_fifo(
    .inst_clk(clk),
    .inst_rst_n(power_on_rst_n),
    .inst_push_req_n(~isu_fifo_wen),
    .inst_pop_req_n(act_busy),
    .inst_diag_n(1'b1),
    .inst_data_in(sch_out),
    .empty_inst(isu_fifo_empty),
    .almost_empty_inst(isu_fifo_almost_empty),
    .half_full_inst( isu_fifo_half_full),
    .almost_full_inst(isu_fifo_vfull),
    .full_inst(isu_fifo_full),
    .error_inst( issue_fifo_error),
    .data_out_inst(isu_fifo_out));

localparam  WRITE_DATA_FIFO_WIDTH =  `DQ_BITS*8;
localparam  WRITE_FIFO_DEPTH = CTRL_FIFO_DEPTH;

wire wdata_fifo_almost_empty;
wire wdata_fifo_half_full;
wire wdata_fifo_error;

DW_fifo_s1_sf_inst #(.width(WRITE_DATA_FIFO_WIDTH),.depth(WRITE_FIFO_DEPTH),.err_mode(2),.rst_mode(0)) wdata_fifo(
    .inst_clk(clk),
    .inst_rst_n(power_on_rst_n),
    .inst_push_req_n(~wdata_fifo_wen),
    .inst_pop_req_n(~wdata_fifo_ren),
    .inst_diag_n(1'b1),
    .inst_data_in(wdata_fifo_in),
    .empty_inst(wdata_fifo_empty),
    .almost_empty_inst( wdata_fifo_almost_empty),
    .half_full_inst( wdata_fifo_half_full),
    .almost_full_inst(wdata_fifo_vfull),
    .full_inst(wdata_fifo_full),
    .error_inst( wdata_fifo_error),
    .data_out_inst(wdata_fifo_out));


localparam  READ_DATA_FIFO_WIDTH =  `DQ_BITS*8;
localparam  READ_FIFO_DEPTH = 6;

wire rdata_fifo_empty;
wire rdata_fifo_almost_empty;
wire rdata_fifo_half_full;
wire rdata_fifo_error;
wire rdata_fifo_vfull;
wire rdata_fifo_full;
wire [READ_DATA_FIFO_WIDTH-1:0] rdata_fifo_out;

// always_ff@(posedge clk or negedge power_on_rst_n)
// begin:READ_DATA_OUTPUT_CTRL
// if(~power_on_rst_n)
//   begin
    // read_data <= 'b0;
    // read_data_valid <= 1'b0;
//   end
//   else
//   begin
    // read_data <= rdata_fifo_out;
    // read_data_valid <= ~rdata_fifo_empty && i_controller_ren ;
//   end
// end
always_comb 
begin: READ_DATA_OUTPUT_CTRL
    if(~power_on_rst_n) 
    begin
        read_data = 'b0;
        read_data_valid = 1'b0;
    end 
    else 
    begin
        read_data = rdata_fifo_out;
        read_data_valid = ~rdata_fifo_empty && i_controller_ren;
    end
end

DW_fifo_s1_sf_inst #(.width(READ_DATA_FIFO_WIDTH),.depth(READ_FIFO_DEPTH),.err_mode(2),.rst_mode(0)) rdata_out_fifo(
    .inst_clk(clk),
    .inst_rst_n(power_on_rst_n),
    .inst_push_req_n(~read_data_buf_valid),
    .inst_pop_req_n(~i_controller_ren),
    .inst_diag_n(1'b1),
    .inst_data_in(RD_buf_all),
    .empty_inst(rdata_fifo_empty),
    .almost_empty_inst( rdata_fifo_almost_empty),
    .half_full_inst( rdata_fifo_half_full),
    .almost_full_inst(rdata_fifo_vfull),
    .full_inst(rdata_fifo_full),
    .error_inst(rdata_fifo_error),
    .data_out_inst(rdata_fifo_out));

assign issue_fifo_stall = rdata_fifo_half_full;

reg out_fifo_wen;
reg [`OUT_FIFO_WIDTH-1:0]out_fifo_in;
reg out_fifo_ren;
wire [`OUT_FIFO_WIDTH-1:0]out_fifo_out;
wire out_fifo_full;
wire out_fifo_vfull;
wire out_fifo_empty;
wire out_fifo_almost_empty;
wire out_fifo_half_full;
wire out_fifo_almost_full;
wire out_fifo_error;

DW_fifo_s1_sf_inst #(.width(2),.depth(READ_FIFO_DEPTH),.err_mode(2),.rst_mode(0)) rw_cmd_out_fifo(
    .inst_clk(clk),
    .inst_rst_n(power_on_rst_n),
    .inst_push_req_n(~out_fifo_wen),
    .inst_pop_req_n(~out_fifo_ren),
    .inst_diag_n(1'b1),
    .inst_data_in(out_fifo_in),
    .empty_inst(out_fifo_empty),
    .almost_empty_inst( out_fifo_almost_empty),
    .half_full_inst( out_fifo_half_full),
    .almost_full_inst(out_fifo_vfull),
    .full_inst(out_fifo_full),
    .error_inst( out_fifo_error),
    .data_out_inst(out_fifo_out));


//==== Sequential =======================

always@(posedge clk or negedge power_on_rst_n)
begin: MODE_REGISTERS
  if(~power_on_rst_n)begin
  MR0 <= `MR0_CONFIG ;
  MR1 <= `MR1_CONFIG ;
  MR2 <= `MR2_CONFIG ;
  MR3 <= `MR3_CONFIG ;
  end else
  begin
  MR0 <= `MR0_CONFIG ;
  MR1 <= `MR1_CONFIG ;
  MR2 <= `MR2_CONFIG ;
  MR3 <= `MR3_CONFIG ;
  end
end

always@(posedge clk or negedge power_on_rst_n)
begin: MAIN_FSM
if(~power_on_rst_n)
  state <= FSM_POWER_UP ;
else
  state <= state_nxt ;
end

always@(posedge clk or negedge power_on_rst_n)
begin: D_FSM
if(~power_on_rst_n)
  d_state <= D_IDLE ;
else
  d_state <= d_state_nxt ;
end

always@(posedge clk or negedge power_on_rst_n)
begin: DQ_FSM
if(power_on_rst_n == 0)
  dq_state <= DQ_IDLE ;
else
  dq_state <= dq_state_nxt ;
end

//time init_cnt
always@(posedge clk or negedge power_on_rst_n)
begin: INIT_CNT
if(power_on_rst_n == 0)
  init_cnt <= `POWER_UP_LATENCY ;
else
  init_cnt <= init_cnt_next ;
end


always@(posedge clk or negedge power_on_rst_n)
begin: D_COUNTER_GROUPS
if(power_on_rst_n == 0) begin
  d0_counter <= 0 ;
  d1_counter <= 0 ;
  d2_counter <= 0 ;
  d3_counter <= 0 ;
  d4_counter <= 0 ;
end
else begin
  d0_counter <= d0_counter_nxt ;
  d1_counter <= d1_counter_nxt ;
  d2_counter <= d2_counter_nxt ;
  d3_counter <= d3_counter_nxt ;
  d4_counter <= d4_counter_nxt ;
end
end

always@(posedge clk or negedge power_on_rst_n) begin
if(power_on_rst_n == 0)
  d_counter_used <= 0 ;
else
  d_counter_used <= d_counter_used_nxt ;
end

//output init_cnt
// always@(posedge clk or negedge power_on_rst_n) begin
// if(power_on_rst_n == 0)
//   o_counter <= 0 ;
// else
//   o_counter <= o_counter_nxt ;
// end


always@(posedge clk or negedge power_on_rst_n)
begin:tCCD_CNT
if(power_on_rst_n == 0)
  tCCD_counter <= 0 ;
else
  case(state_nxt)
    FSM_READ,
    FSM_WRITE     : tCCD_counter <=$unsigned(`CYCLE_TCCD - 1) ;
    FSM_WAIT_TCCD : tCCD_counter <= tCCD_counter - 1 ;
    default        : tCCD_counter <= (tCCD_counter == 0) ? 0 : tCCD_counter - 1 ;
  endcase
end

always@(posedge clk or negedge power_on_rst_n)
begin: tRTW_CNT
if(power_on_rst_n == 0)
  tRTW_counter <= 0 ;
else
  case(state_nxt)
    FSM_READ      : tRTW_counter <= $unsigned(`CYCLE_TRTW - 1) ;
    FSM_WAIT_TRTW : tRTW_counter <=  tRTW_counter - 1 ;
    default        : tRTW_counter <= (tRTW_counter == 0) ? 0 : tRTW_counter - 1 ;
  endcase
end

always@(posedge clk or negedge power_on_rst_n)
begin: tWTR_CNT
if(power_on_rst_n == 0)
  tWTR_counter <= 0 ;
else
  case(state_nxt)
    FSM_WRITE      : if(MR0[1:0] == 2'b01)
                        tWTR_counter <= $unsigned(`CYCLE_TOTAL_WL+`CYCLE_TWTR+4-1) ;
                      else if(MR0[1:0] == 2'b00)
                        tWTR_counter <= $unsigned(`CYCLE_TOTAL_WL+`CYCLE_TWTR+4-1) ;
                      else
                        tWTR_counter <= $unsigned(`CYCLE_TOTAL_WL+`CYCLE_TWTR+2-1) ;

    FSM_READY      : tWTR_counter <= (tWTR_counter == 0) ? 0 : tWTR_counter - 1 ;
    FSM_WAIT_TWTR  : tWTR_counter <=  tWTR_counter - 1 ;
    default         : tWTR_counter <= (tWTR_counter == 0) ? 0 : tWTR_counter - 1 ;
  endcase
end

always@*
begin: OUT_FIFO_REN_DECODE
if(d_state_nxt == D_WRITE_F || d_state_nxt == D_READ_F)
  out_fifo_ren = 1 ;
else
  out_fifo_ren = 0 ;
end

always@*
begin: OUT_FIFO_WEN_DATA_DECODE
  if(state == FSM_WRITE) begin // Write is 0!!! Read is 1
  	out_fifo_wen = 1 ;
    out_fifo_in = {1'b0,1'b1} ; // {read/write,Burst_Length} ;
  end
  else if (state == FSM_READ) begin
  	out_fifo_wen = 1 ;
    out_fifo_in = {1'b1,1'b1} ; // {read/write,Burst_Length} ;
  end
  else begin
  	out_fifo_wen = 0 ;
  	out_fifo_in = 0 ;
  end
end

//time init_cnt
always@(posedge clk2 or negedge power_on_rst_n)
begin: DQ_CNT
if(~power_on_rst_n)
  dq_counter <= 0 ;
else
  dq_counter <= dq_counter_nxt ;
end

//active busy control, must be synchronise with the main FSM, main FSM is in charge of the command to schedule
always@*
begin: ACT_BUSY_BLOCK

act_busy = 1'b1;

if(issue_fifo_stall || isu_fifo_empty)begin
  act_busy = 1'b1 ;
end
else
begin
 case(state)
   FSM_READ   : act_busy = 1'b0 ;
   FSM_WRITE  : act_busy = 1'b0 ;
   FSM_PRE    : act_busy = 1'b0 ;
   FSM_ACTIVE : act_busy = 1'b0 ;
   FSM_READY  : act_busy = 1'b0 ;
   default     : act_busy = 1'b1 ;
 endcase
end
end

issue_fifo_cmd_in_t isu_fifo_out_cmd , isu_fifo_out_cmd_pre ;

always_comb begin
  isu_fifo_out_cmd     = issue_fifo_cmd_in_t'(isu_fifo_out) ;
  isu_fifo_out_cmd_pre = issue_fifo_cmd_in_t'(isu_fifo_out_pre) ;
end

always@(posedge clk or negedge power_on_rst_n)
begin: ACT_BANK_CMD_FF
if(~power_on_rst_n)
begin
  act_bank    <= 0 ;
  act_addr    <= 0 ;
  act_command <= ATCMD_NOP ;
end
else if(act_busy==0)
    if(isu_fifo_empty==0) begin
       act_bank    <= isu_fifo_out_cmd.bank ;
       act_addr    <= isu_fifo_out_cmd.addr ;
       act_command <= isu_fifo_out_cmd.command ;
    end
    else begin
       act_bank    <= 0 ;
       act_addr    <= 0 ;
       act_command <= ATCMD_NOP ;
    end
else begin
 act_bank    <= act_bank ;
 act_addr    <= act_addr ;
 act_command <= act_command ;
end

end


always_comb
begin: WR_DATA_FIFO_CTRL_DECODE

  if(ba0.command_in.r_w == WRITE && receive_command_handshake_f) //write command
  begin
    wdata_fifo_wen=1'b1 ;
    wdata_fifo_in = write_data ; // {data,burst_length}
  end
  else
  begin
    wdata_fifo_wen = 1'b0 ;
    wdata_fifo_in  = 'd0;
  end

  if( d_state == D_WRITE_F &&  wdata_fifo_empty == 1'b0)
    wdata_fifo_ren = 1'b1 ;
  else
    wdata_fifo_ren = 1'b0 ;

end

always_comb
begin: BANK_STATUS_DECODE_BLOCK
if(isu_fifo_vfull || wdata_fifo_vfull)
  ba_cmd_pm = 1'b0 ;
else
  ba_cmd_pm = ~{ba0_busy}  ;
end

always@(posedge clk or negedge power_on_rst_n)
begin: BURST_LENGTH_CTRL
if(power_on_rst_n == 0)
  process_BL <= 0 ;
else
  if(d_state == D_IDLE)
    process_BL <= 0 ;
  else
    process_BL <= (W_BL) ? $unsigned(3) : $unsigned(3) ; // Both using a burst length delay of 4
end


always@(posedge clk or negedge power_on_rst_n) begin
if(power_on_rst_n == 0)
  read_data_buf_valid <= 0 ;
else
  if(d_state_nxt == `D_READ_F)
    read_data_buf_valid <= 1 ;
  else
    read_data_buf_valid <= 0 ;
end

//====================================================
//Physical layer tranform
//====================================================
// {cke,cs_n,ras_n,cas_n,we_n}
always@(negedge clk or negedge power_on_rst_n)
begin: DRAM_PHY_CK_CS_RAS_CAS_WE
  if(~power_on_rst_n) begin
      {cke,cs_n,ras_n,cas_n,we_n} <= `CMD_POWER_UP ;
  end
  else begin
    case(state)
      FSM_POWER_UP : {cke,cs_n,ras_n,cas_n,we_n} <= `CMD_POWER_UP ;
      FSM_ZQ       : {cke,cs_n,ras_n,cas_n,we_n} <= `CMD_ZQ_CALIBRATION ;
      FSM_LMR0,
      FSM_LMR1,
      FSM_LMR2,
      FSM_LMR3     : {cke,cs_n,ras_n,cas_n,we_n} <= `CMD_LOAD_MODE ;
      FSM_ACTIVE   : {cke,cs_n,ras_n,cas_n,we_n} <= `CMD_ACTIVE ;
      FSM_READ     : {cke,cs_n,ras_n,cas_n,we_n} <= `CMD_READ ;
      FSM_WRITE    : {cke,cs_n,ras_n,cas_n,we_n} <= `CMD_WRITE ;
      FSM_PRE      : {cke,cs_n,ras_n,cas_n,we_n} <= `CMD_PRECHARGE ;
      FSM_REFRESH  : {cke,cs_n,ras_n,cas_n,we_n} <= `CMD_REFRESH ;
      default : {cke,cs_n,ras_n,cas_n,we_n} <= `CMD_NOP ;
    endcase
  end
end

always@(negedge clk or negedge power_on_rst_n) begin: DRAM_PHY_ADDR
  if(~power_on_rst_n) begin
    addr <= 0 ;
  end
  else begin
    case(state)
      FSM_ZQ       : addr <= 1024 ; //A10 = 1 ;
      FSM_LMR0     : addr <= MR0;
      FSM_LMR1     : addr <= MR1;
      FSM_LMR2     : addr <= MR2;
      FSM_LMR3     : addr <= MR3;
      FSM_ACTIVE   : addr <= act_addr ;
      FSM_READ,FSM_READA     : addr <= act_addr ;
      FSM_WRITE,FSM_WRITEA    : addr <= act_addr ;
      FSM_PRE      : addr <= act_addr ;
      default : addr <= addr ;
    endcase
  end
end

always@(negedge clk or negedge power_on_rst_n) begin: DRAM_PHY_BA
  if(~power_on_rst_n) begin
    ba <= 0 ;
  end
  else begin
    case(state)
      FSM_ZQ       : ba <= 0 ; //A10 = 1 ;
      FSM_LMR0     : ba <= 0 ;
      FSM_LMR1     : ba <= 1 ;
      FSM_LMR2     : ba <= 2 ;
      FSM_LMR3     : ba <= 3 ;
      FSM_ACTIVE   : ba <= 0;//act_bank ;
      FSM_READ,FSM_READA     : ba <= 0;//act_bank ;
      FSM_WRITE ,FSM_WRITEA   : ba <= 0;//act_bank ;
      FSM_PRE      : ba <= 0;//act_bank ;
      FSM_REFRESH  : ba <= 0 ;
      default : ba <= ba ;
    endcase
  end
end


logic ddr3_rw_d1_nff;
//pad_rw
always@(negedge clk or negedge power_on_rst_n) // Strange thing appears here
begin: DRAM_PHY_RW
  if(~power_on_rst_n)
  begin
    ddr3_rw_d1_nff <= 1'b1 ;
  end
  else
  begin
    case(d_state)
      D_READ1   : ddr3_rw_d1_nff <= 1'b1 ;
      D_READ2   : ddr3_rw_d1_nff <= 1'b1 ;
      D_READ_F  : ddr3_rw_d1_nff <= 1'b1 ;

      D_WRITE1  : ddr3_rw_d1_nff <= 1'b0 ;
      D_WRITE2  : ddr3_rw_d1_nff <= 1'b0 ;
      D_WRITE_F : ddr3_rw_d1_nff <= 1'b0 ;
    default  : ddr3_rw_d1_nff <= 1'b1 ;
    endcase
  end
end


always_ff@(negedge clk or negedge power_on_rst_n) begin
  if(~power_on_rst_n)
    ddr3_rw <= 1'b0;
  else
    ddr3_rw <= ddr3_rw_d1_nff;
end

logic odt_d1_nff;

always_ff@(negedge clk or negedge power_on_rst_n) begin
  if(~power_on_rst_n)
    odt_d1_nff <= 1'b0;
  else
    odt_d1_nff <= odt_d1_nff;
end

//odt control
always@(negedge clk or negedge power_on_rst_n)
begin: ODT_CTR
if(power_on_rst_n == 0)
  odt <= 0 ;
else
  case(state)
    FSM_READ,FSM_READA  : odt <= 0 ;
    FSM_WRITE,FSM_WRITEA : odt <= 0 ;
    default : odt <= odt ;
  endcase
end

always@(negedge clk or negedge power_on_rst_n)
begin: NEG_OUT_FF
if(power_on_rst_n == 0)
  out_ff <= 0 ;
else
  out_ff <= (d_state == D_WRITE1 || d_state == D_WRITE2) ? ~out_ff : 0 ;

end

always@(posedge clk2 or negedge power_on_rst_n)
begin: CLK2_DQS_OUT
  if(~power_on_rst_n) begin
    dqs_out <= 2'b00 ;
    dqs_n_out <= 2'b00 ;
  end
  else begin
    dqs_out <= dqs_out_nxt ;
	  dqs_n_out <= dqs_n_out_nxt ;
  end
end

always@*
begin: DQS_DATA_CONTROL
	case(d_state)
    `D_WRITE1 : begin
                  if(dqs_out == 2'b11) begin
                    dqs_out_nxt = ~dqs_out ;
                    dqs_n_out_nxt = ~dqs_n_out ;
                  end
                  else begin
    	              dqs_out_nxt =   (out_ff) ? 2'b11 : 2'b00 ;
    	              dqs_n_out_nxt = (out_ff) ? 2'b00 : 2'b11 ;
    	            end
    	          end
    `D_WRITE2 : begin
                  dqs_out_nxt = ~dqs_out ;
                  dqs_n_out_nxt = ~dqs_n_out ;
                end
    `D_WRITE_F: if(d0_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) || d1_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) ||
                   d2_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) || d3_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) ||
                   d4_counter == $unsigned(`CYCLE_TOTAL_WL-1-1)) begin

                   dqs_out_nxt = ~dqs_out ;
                   dqs_n_out_nxt = ~dqs_n_out ;

                end
                else if(d0_counter == $unsigned(`CYCLE_TOTAL_WL-1) || d1_counter == $unsigned(`CYCLE_TOTAL_WL-1) ||
                        d2_counter == $unsigned(`CYCLE_TOTAL_WL-1) || d3_counter == $unsigned(`CYCLE_TOTAL_WL-1) ||
                        d4_counter == $unsigned(`CYCLE_TOTAL_WL-1)) begin

                   dqs_out_nxt = ~dqs_out ;
                   dqs_n_out_nxt = ~dqs_n_out ;
                end
                else if(d0_counter == $unsigned(`CYCLE_TOTAL_WL-1+1) || d1_counter == $unsigned(`CYCLE_TOTAL_WL-1+1) ||
                        d2_counter == $unsigned(`CYCLE_TOTAL_WL-1+1) || d3_counter == $unsigned(`CYCLE_TOTAL_WL-1+1) ||
                        d4_counter == $unsigned(`CYCLE_TOTAL_WL-1+1)) begin

                   dqs_out_nxt = ~dqs_out ;
                   dqs_n_out_nxt = ~dqs_n_out ;
                end
                else begin
                   dqs_out_nxt = ~dqs_out ;
                   dqs_n_out_nxt = ~dqs_n_out ;
                end
    `D_READ_F  :begin
                   dqs_out_nxt = 2'b11 ;
                   dqs_n_out_nxt = 2'b00 ;
                end
    default    : begin
    	             dqs_out_nxt = 2'b00 ;
    	             dqs_n_out_nxt = 2'b11 ;
    	           end
  endcase
end

always@(posedge clk) begin
  data_all_out <= data_all_out_nxt ;
end

always@(posedge clk2) begin
  dm_tdqs_out <= dm_tdqs_out_nxt ;
end

always@*
begin: TDQS_CONTROL
  dm_tdqs_out_nxt = dm_tdqs_out ;
  if(dq_state == DQ_OUT)
  begin
    if(W_BL==0) //Burst Length = 4
      dm_tdqs_out_nxt = (dq_counter <= 3) ? 2'b00 : 2'b11 ;
    else //Burst_Length = 8
      dm_tdqs_out_nxt = (dq_counter <= 7) ? 2'b00 : 2'b11 ;
  end
  else
    dm_tdqs_out_nxt = 2'b11 ;
end

// Simulation TEST signals
// always@(negedge clk)
// begin: RD_BUF_EVEN

// RD_buf[0] <= (dq_counter == 2 && (d_state == D_READ2 || d_state == D_WAIT_CL_READ) ) ? RD_temp : RD_buf[0];
// RD_buf[2] <= (dq_counter == 2 && d_state == D_READ2) ? data_in : RD_buf[2];
// RD_buf[4] <= (dq_counter == 4 && d_state ==D_READ2) ? data_in : RD_buf[4];
// RD_buf[6] <= (dq_counter == 6 && d_state == D_READ2) ? data_in : RD_buf[6];

// end

// always@(posedge clk) begin: RD_BUF_ODD

// RD_buf[1] <= (dq_counter == 1 && (d_state == D_READ2 || d_state == D_READ_F) ) ? data_in : RD_buf[1];
// RD_buf[3] <= (dq_counter == 3 && d_state == D_READ2) ? data_in : RD_buf[3];
// RD_buf[5] <= (dq_counter == 5 && d_state == D_READ2) ? data_in : RD_buf[5];
// RD_buf[7] <= (dq_counter == 7 && d_state == D_READ2) ? data_in : RD_buf[7];

// end

always_comb
begin:RD_BUF_ALL
   RD_buf_all = (dq_counter == 1 && (d_state == D_READ2 || d_state == D_READ_F) ) ? data_all_in : RD_buf_all;
end

// always@(negedge clk) begin:RD_TEMP
// case(d_state)

//   D_READ_F  :  RD_temp <= data_in ;

//   D_READ2   :  RD_temp <= data_in ;

//   default    :  RD_temp <= RD_temp ;

// endcase
// end

//synopsys translate_off
always_comb
begin: PRE_COMMAND_DECODER_BLOCK
    if(isu_fifo_empty==0) // FIFO is not empty
    begin
       pre_bank = isu_fifo_out_cmd_pre.bank ;
       pre_addr = isu_fifo_out_cmd_pre.addr ;
       pre_cmd  = isu_fifo_out_cmd_pre.command ;
    end
    else
    begin // ISSUE FIFO is empty
       pre_bank = 0 ;
       pre_addr = 0 ;
       pre_cmd  = ATCMD_NOP ;
    end
end
//synopsys translate_on

//====================================================
//ISSUE BUFFER
//====================================================
always_comb
begin: TP_CNT_BLOCK
  tP_ba_cnt  = tP_ba0_counter ;
if(tP_ba0_counter==0)
  tP_all_zero = 1 ;
else
  tP_all_zero = 0 ;

end

always_comb
begin: TIMING_CONSTRAINT_RECODE
    tP_recode_state = tP_c0_recode ;
end

always@*
begin: RAS_COUNTER
  tRAS_ba_cnt  = tRAS0_counter ;
end

always@*
begin: F_BANK_BLOCK
case(state)
  FSM_READY  : f_bank = now_bank ;
  FSM_READ,
  FSM_WRITE,
  FSM_PRE,
  FSM_READA,
  FSM_WRITEA,
  FSM_ACTIVE : f_bank = now_bank ;
  default     : f_bank = act_bank ;
endcase
end

always@*
begin: F_AUTO_PRE_BLOCK
case(state)
  FSM_READY  : f_auto_pre = now_addr[10] ;
  FSM_READ,
  FSM_WRITE,
  FSM_PRE,
  FSM_ACTIVE : f_auto_pre = now_addr[10] ;
  default     : f_auto_pre = act_addr[10] ;
endcase
end

logic check_tRC_violation_flag;
logic check_tRP_violation_flag;
logic check_tWTR_violation_flag;
logic check_tRCD_violation_flag;
logic check_tCCD_violation_flag;
logic check_tRTW_violation_flag;
logic check_tRAS_violation_flag;
logic check_tWR_violation_flag;
logic check_tRTP_violation_flag;

always_comb
begin
  // Initialization
  check_tRP_violation_flag = 0;
  check_tRC_violation_flag = 0;
  check_tWTR_violation_flag = 0;
  check_tRCD_violation_flag = 0;
  check_tCCD_violation_flag = 0;
  check_tRTW_violation_flag = 0;
  check_tRAS_violation_flag = 0;
  check_tWR_violation_flag = 0;
  check_tRTP_violation_flag = 0;

  // Flag checker
  case(state)
    FSM_READ, FSM_WRITE, FSM_PRE, FSM_ACTIVE, FSM_READY: begin
      case(now_issue)
        ATCMD_ACTIVE: begin
          check_tRC_violation_flag = (tRAS_ba_cnt != 1'b0) ? 1'b1 : 1'b0;
          check_tRP_violation_flag = (tP_ba_cnt != 1'b0 && (tP_recode_state == CODE_PRECHARGE_TO_ACTIVE || tP_recode_state == CODE_WRITE_TO_ACTIVE || tP_recode_state == CODE_READ_TO_ACTIVE)) ? 1'b1 : 1'b0;
        end
        ATCMD_READ: begin
          check_tWTR_violation_flag = (tWTR_counter != 1'b0) ? 1'b1 : 1'b0;
          check_tRCD_violation_flag = (tP_ba_cnt != 1'b0 && tP_recode_state == CODE_ACTIVE_TO_READ_WRITE) ? 1'b1 : 1'b0;
          check_tCCD_violation_flag = (tCCD_counter != 1'b0) ? 1'b1 : 1'b0;
        end
        ATCMD_WRITE: begin
          check_tRCD_violation_flag = (tP_ba_cnt != 1'b0 && tP_recode_state == CODE_ACTIVE_TO_READ_WRITE) ? 1'b1 : 1'b0;
          check_tCCD_violation_flag = (tCCD_counter != 1'b0) ? 1'b1 : 1'b0;
          check_tRTW_violation_flag = (tCCD_counter != 1'b0 || tRTW_counter != 0) ? 1'b1 : 1'b0;
        end
        ATCMD_PRECHARGE:begin
          check_tRAS_violation_flag = (tRAS_ba_cnt >= $unsigned(`CYCLE_TRC-`CYCLE_TRAS)) ? 1'b1 : 1'b0;
          check_tWR_violation_flag = (tP_ba_cnt != 1'b0 && tP_recode_state == CODE_WRITE_TO_PRECHARGE) ? 1'b1 : 1'b0;
          check_tRTP_violation_flag = (tP_ba_cnt != 1'b0 && tP_recode_state == CODE_READ_TO_PRECHARGE) ? 1'b1 : 1'b0;
        end
        ATCMD_REFRESH: begin
          check_tRP_violation_flag = (tP_ba_cnt != 1'b0 && (tP_recode_state == CODE_PRECHARGE_TO_ACTIVE || tP_recode_state == CODE_WRITE_TO_ACTIVE || tP_recode_state == CODE_READ_TO_ACTIVE)) ? 1'b1 : 1'b0;
        end
        default: begin
          check_tRC_violation_flag = 1'b0;
          check_tRP_violation_flag = 1'b0;
          check_tWTR_violation_flag = 1'b0;
          check_tRCD_violation_flag = 1'b0;
          check_tCCD_violation_flag = 1'b0;
          check_tRTW_violation_flag = 1'b0;
        end
      endcase
    end
    FSM_WAIT_TRC: begin
      check_tRC_violation_flag = (tRAS_ba_cnt != 1'b0) ? 1'b1 : 1'b0;
      check_tRP_violation_flag = (tP_ba_cnt!=1'b0 && (tP_recode_state == CODE_PRECHARGE_TO_REFRESH|| tP_recode_state==CODE_PRECHARGE_TO_ACTIVE || tP_recode_state==CODE_WRITE_TO_ACTIVE || tP_recode_state==CODE_READ_TO_ACTIVE)) ? 1'b1 : 1'b0;
    end
    FSM_WAIT_TCCD: begin
      check_tCCD_violation_flag = (tCCD_counter == 1'b0) ? 1'b1 : 1'b0;
    end
    FSM_WAIT_TRTW: begin
      check_tRTW_violation_flag = (tCCD_counter == 1'b0 && tRTW_counter == 1'b0) ? 1'b1 : 1'b0;
    end
    FSM_WAIT_TWTR: begin
      check_tWTR_violation_flag = (tWTR_counter == 1'b0) ? 1'b1 : 1'b0;
      check_tRCD_violation_flag = (tP_ba_cnt != 1'b0 && tP_recode_state == CODE_ACTIVE_TO_READ_WRITE) ? 1'b1 : 1'b0;
    end
    FSM_WAIT_TRAS: begin
      check_tRAS_violation_flag = (tRAS_ba_cnt >= $unsigned(`CYCLE_TRC-`CYCLE_TRAS)) ? 1'b1 : 1'b0;
    end
    FSM_REFRESH,FSM_REFRESHING,FSM_WAIT_TRP: begin
      check_tRP_violation_flag = (tP_ba_cnt != 1'b0 && (tP_recode_state == CODE_PRECHARGE_TO_REFRESH|| tP_recode_state == CODE_PRECHARGE_TO_ACTIVE || tP_recode_state == CODE_WRITE_TO_ACTIVE || tP_recode_state == CODE_READ_TO_ACTIVE)) ? 1'b1 : 1'b0;
    end
    default: begin
      check_tRC_violation_flag = 1'b0;
      check_tRP_violation_flag = 1'b0;
      check_tWTR_violation_flag = 1'b0;
      check_tRCD_violation_flag = 1'b0;
      check_tCCD_violation_flag = 1'b0;
      check_tRTW_violation_flag = 1'b0;
    end
  endcase
end

wire precharge_all_f = (now_addr[10] == 1'b1) ? 1'b1 : 1'b0 ;

always_comb begin
  // Grabs the command from the issue fifo, then decode the command and start checking the timing constraints
	now_issue = (isu_fifo_empty||issue_fifo_stall) ? ATCMD_NOP : isu_fifo_out_cmd.command ;
  now_bank = (isu_fifo_empty||issue_fifo_stall) ? 1'b0 : isu_fifo_out_cmd.bank ;
  now_addr = (isu_fifo_empty||issue_fifo_stall) ? 1'b0 : isu_fifo_out_cmd.addr ;
end

//command state
always_comb
begin: MAIN_FSM_NEXT_BLOCK
  state_nxt = state;

  case(state)
   // Initialization
   FSM_POWER_UP  : state_nxt = (init_cnt == $unsigned(0)) ? FSM_WAIT_TXPR : FSM_POWER_UP  ;
   FSM_WAIT_TXPR : state_nxt = (init_cnt == $unsigned(0)) ? FSM_ZQ : FSM_WAIT_TXPR ;
   FSM_ZQ        : state_nxt = FSM_LMR0 ;
   FSM_LMR0      : state_nxt = FSM_WAIT_TMRD ;
   FSM_WAIT_TMRD : case(init_cnt)
                     $unsigned(7) : state_nxt = FSM_LMR1 ;
                     $unsigned(4) : state_nxt = FSM_LMR2 ;
                     $unsigned(1) : state_nxt = FSM_LMR3 ;
                     default : state_nxt = state ;
                    endcase
   FSM_LMR1     : state_nxt = FSM_WAIT_TMRD ;
   FSM_LMR2     : state_nxt = FSM_WAIT_TMRD ;
   FSM_LMR3     : state_nxt = FSM_WAIT_TDLLK ;
   FSM_WAIT_TDLLK : state_nxt = (init_cnt == $unsigned(0)) ? FSM_IDLE : FSM_WAIT_TDLLK ;

   // Controller online
   FSM_IDLE      : state_nxt = FSM_READY ;

   // Bank is Refreshing
   FSM_REFRESH   : state_nxt = FSM_REFRESHING ;
   FSM_REFRESHING: state_nxt = bank_refresh_completed ? FSM_READY : FSM_REFRESHING ;
   FSM_READ,
   FSM_WRITE,
   FSM_PRE,
   FSM_ACTIVE,
   FSM_READA,
   FSM_WRITEA,
   // TODO Add ATCMD_WRA,ATCMD_RDA
   FSM_READY     :  case(now_issue) // When issuing command, checks for the timing violation
                       ATCMD_REFRESH  : state_nxt = FSM_WAIT_TRP ; // This needs to be modified to wait TRP instead.
                       ATCMD_NOP      : state_nxt = FSM_READY ;
                       ATCMD_ACTIVE   : if(check_tRC_violation_flag == 1'b1)//tRC violation
                                           state_nxt = FSM_WAIT_TRC ;
                                         else if(check_tRP_violation_flag == 1'b1 )//tRP violation
                                           state_nxt = FSM_WAIT_TRP ;
                                         else//no violation
                                           state_nxt = FSM_ACTIVE ;

                       ATCMD_READ     :if(check_tWTR_violation_flag == 1'b1) // tWTR violation
                                          state_nxt = FSM_WAIT_TWTR ;
                                        else if(check_tRCD_violation_flag == 1'b1)//tRCD violation
                                          state_nxt = FSM_WAIT_TRCD ;
                                        else if(check_tCCD_violation_flag == 1'b1) //tCCD violation
                                          state_nxt = FSM_WAIT_TCCD ;
                                        else
                                          state_nxt = FSM_READ ;


                       ATCMD_WRITE    : if(check_tRCD_violation_flag == 1'b1)//tRCD violation
                                          state_nxt = FSM_WAIT_TRCD ;
                                        else if(check_tCCD_violation_flag == 1'b1 || check_tRTW_violation_flag == 1'b1)//tCCD violation or tRTW violation
                                          if(tCCD_counter>=tRTW_counter)
                                            state_nxt = FSM_WAIT_TCCD ;
                                          else
                                            state_nxt = FSM_WAIT_TRTW ;
                                        else
                                          state_nxt = FSM_WRITE ;

                       ATCMD_PRECHARGE,ATCMD_RDA,ATCMD_WRA:
                                        if(check_tRAS_violation_flag == 1'b1) //tRAS violation
                                          state_nxt = FSM_WAIT_TRAS ;
                                        else if(check_tWR_violation_flag == 1'b1)//tWR violation
                                          state_nxt = FSM_WAIT_TWR ;
                                        else if(check_tRTP_violation_flag == 1'b1)//tRTP violation
                                          state_nxt = FSM_WAIT_TRTP ;
                                        else
                                          state_nxt = FSM_PRE ;
                       default         : state_nxt = state ;
                     endcase

   FSM_WAIT_TRC : if(check_tRC_violation_flag == 1'b1)//tRC violation
                     state_nxt = FSM_WAIT_TRC ;
                   else
                     if(check_tRP_violation_flag == 1'b1)//tRP violation
                       state_nxt = FSM_WAIT_TRP ;
                     else
                       state_nxt = FSM_ACTIVE ;

   FSM_WAIT_TCCD: if(check_tCCD_violation_flag == 1'b1)// tCCD violation
                     if(act_command == ATCMD_READ) // Check if it is read or write
                       state_nxt = FSM_READ ;
                     else if (act_command == ATCMD_WRITE)
                       state_nxt = FSM_WRITE ;
                     else
                       state_nxt = state ;
                   else // Waiting for tCCD
                     state_nxt = FSM_WAIT_TCCD ;

   FSM_WAIT_TRCD,
   FSM_WAIT_TWR,
   FSM_WAIT_TRP,
   FSM_WAIT_TRTP:
                  // CHECK VIOLATIONs
                  if(tP_ba_cnt==0)
                    case(tP_recode_state)
                      CODE_IDLE       : state_nxt = FSM_PRE ;
                      CODE_PRECHARGE_TO_ACTIVE,
                      CODE_WRITE_TO_ACTIVE,
                      CODE_READ_TO_ACTIVE: state_nxt = FSM_ACTIVE ;

                      CODE_ACTIVE_TO_READ_WRITE : 
                                if(act_command == ATCMD_READ)
                                  if(tCCD_counter==0)
                                    state_nxt = FSM_READ ;
                                  else
                                    state_nxt = FSM_WAIT_TCCD ;
                                else if(act_command == ATCMD_WRITE)
                                  if(tCCD_counter==0 && tRTW_counter==0)
                                    state_nxt = FSM_WRITE ;
                                  else if(tCCD_counter >= tRTW_counter)
                                    state_nxt = FSM_WAIT_TCCD ;
                                  else
                                    state_nxt = FSM_WAIT_TRTW ;
                                else
                                  state_nxt = state ;

                      CODE_READ_TO_PRECHARGE: state_nxt = FSM_PRE ;
                      CODE_PRECHARGE_TO_REFRESH : 
                                if(check_tRP_violation_flag == 1'b0)
                                  state_nxt = FSM_REFRESH ;
                                else
                                  state_nxt = FSM_WAIT_TRP;
                      default : state_nxt = FSM_PRE ;
                    endcase
                  else
                    state_nxt = state ;

   FSM_WAIT_TRTW: state_nxt = check_tRTW_violation_flag == 1'b1 ? FSM_WRITE : FSM_WAIT_TRTW ; // tRTW violation
   FSM_WAIT_TWTR: if(check_tWTR_violation_flag == 1'b1) // check tWTR violation
                     if(check_tRCD_violation_flag == 1'b1)//check tRCD violation
                       state_nxt = FSM_WAIT_TRCD ;
                     else
                       state_nxt = FSM_READ ;
                   else
                     state_nxt = FSM_WAIT_TWTR ;
	 FSM_WAIT_TRAS:
                   if(check_tRAS_violation_flag == 1'b1)begin //tRAS violation
                     state_nxt = FSM_WAIT_TRAS ;
                   end
	                 else begin
	                   if(tP_ba_cnt!=0) // tW, tRTP violation
	                     case(tP_recode_state)
	                       $unsigned(1)      : state_nxt = FSM_WAIT_TWR ;
	                       $unsigned(4)      : state_nxt = FSM_WAIT_TRTP ;
	                       default: state_nxt = FSM_PRE ;
	                     endcase
                   end
   FSM_PRE        : state_nxt = FSM_READY ;

   default : state_nxt = state ;
  endcase
end

always_comb
begin:INITIALIZATION_COUNTER
  init_cnt_next = init_cnt;
  case(state)
    FSM_POWER_UP  : init_cnt_next = (state_nxt == FSM_POWER_UP) ? init_cnt - 1 : `CYCLE_TXPR ;
    FSM_WAIT_TXPR : init_cnt_next = (state_nxt == FSM_WAIT_TXPR) ? init_cnt - 1 : 0 ;
    FSM_ZQ        : init_cnt_next = `CYCLE_TMRD ;
    FSM_WAIT_TMRD : init_cnt_next =  init_cnt - 1 ;
    FSM_LMR3      : init_cnt_next = `CYCLE_TDLLK ;
    FSM_WAIT_TDLLK: init_cnt_next = init_cnt - 1 ;
    default : init_cnt_next = init_cnt ;
  endcase
end

// d control state defination. for AL,CL controls
always@*
begin: DQ_CONTROLLER
   d_state_nxt = d_state ;
   case(d_state)
   D_IDLE     : if(state == FSM_READ)
                   d_state_nxt = D_WAIT_CL_READ ;
                 else if (state == FSM_WRITE)
                   d_state_nxt = D_WAIT_CL_WRITE ;
                 else
                   d_state_nxt = D_IDLE ;
   D_WAIT_CL_READ  : d_state_nxt = ( d0_counter >= $unsigned(`CYCLE_TOTAL_RL-1) || // Read latency
                                     d1_counter >= $unsigned(`CYCLE_TOTAL_RL-1) ||
                                     d2_counter >= $unsigned(`CYCLE_TOTAL_RL-1) ||
                                     d3_counter >= $unsigned(`CYCLE_TOTAL_RL-1) ||
                                     d4_counter >= $unsigned(`CYCLE_TOTAL_RL-1)  ) ? D_READ1 : D_WAIT_CL_READ ;

   D_WAIT_CL_WRITE : d_state_nxt = (d0_counter >= $unsigned(`CYCLE_TOTAL_WL-1-1) || // Write latency
                                     d1_counter >= $unsigned(`CYCLE_TOTAL_WL-1-1) ||
                                     d2_counter >= $unsigned(`CYCLE_TOTAL_WL-1-1) ||
                                     d3_counter >= $unsigned(`CYCLE_TOTAL_WL-1-1) ||
                                     d4_counter >= $unsigned(`CYCLE_TOTAL_WL-1-1)  ) ? D_WRITE1 : D_WAIT_CL_WRITE ;
   D_WRITE1    : d_state_nxt = D_WRITE2 ;
   D_WRITE2    : d_state_nxt = (dq_counter[2:0] == process_BL) ? D_WRITE_F : D_WRITE2 ;
   D_WRITE_F   :if(d_counter_used == 0) // Corresponding to the burst length of 4?
		               if(state==FSM_WRITE)
                     d_state_nxt = D_WAIT_CL_WRITE ;
                   else if(state==FSM_READ)
                     d_state_nxt = D_WAIT_CL_READ ;
                   else
		                 d_state_nxt = D_IDLE ;
		             else
		               if(d0_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) || d1_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) ||
		                  d2_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) || d3_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) ||
		                  d4_counter == $unsigned(`CYCLE_TOTAL_WL-1-1)  )
		                 d_state_nxt = D_WRITE1 ;
		               else if(d0_counter == $unsigned(`CYCLE_TOTAL_WL-1) || d1_counter == $unsigned(`CYCLE_TOTAL_WL-1) ||
		                       d2_counter == $unsigned(`CYCLE_TOTAL_WL-1) || d3_counter == $unsigned(`CYCLE_TOTAL_WL-1) ||
		                       d4_counter == $unsigned(`CYCLE_TOTAL_WL-1)  )
		                 d_state_nxt = D_WRITE2 ;
		               else if(d0_counter == $unsigned(`CYCLE_TOTAL_WL-1+1) || d1_counter == $unsigned(`CYCLE_TOTAL_WL-1+1) ||
		                       d2_counter == $unsigned(`CYCLE_TOTAL_WL-1+1) || d3_counter == $unsigned(`CYCLE_TOTAL_WL-1+1) ||
		                       d4_counter == $unsigned(`CYCLE_TOTAL_WL-1+1)  )
		                 d_state_nxt = D_WRITE2 ;
		               else
		                 d_state_nxt = D_WAIT_CL_WRITE ;

   D_READ1    : d_state_nxt = D_READ2 ;
   D_READ2    : d_state_nxt = (dq_counter[2:0] == process_BL) ?D_READ_F : D_READ2 ;
   D_READ_F   : if(d_counter_used == 0) // Corresponding to the burst length of 4?
		               if(state==FSM_WRITE)
                     d_state_nxt = D_WAIT_CL_WRITE ;
                   else if(state==FSM_READ)
                     d_state_nxt = D_WAIT_CL_READ ;
                   else
                     d_state_nxt = D_IDLE ;
		            else begin
                  if(out_fifo_out[1] == 1'b0) begin  //write
				                if(d0_counter == `CYCLE_TOTAL_WL-1-1 || d1_counter == `CYCLE_TOTAL_WL-1-1 ||
				                   d2_counter == `CYCLE_TOTAL_WL-1-1 || d3_counter == `CYCLE_TOTAL_WL-1-1 ||
				                   d4_counter == `CYCLE_TOTAL_WL-1-1  )

				                  d_state_nxt = D_WRITE1 ;


				                else if(d0_counter == `CYCLE_TOTAL_WL-1 || d1_counter == `CYCLE_TOTAL_WL-1 ||
				                        d2_counter == `CYCLE_TOTAL_WL-1 || d3_counter == `CYCLE_TOTAL_WL-1 ||
				                        d4_counter == `CYCLE_TOTAL_WL-1  )

				                  d_state_nxt = D_WRITE2 ;

				                else if(d0_counter == `CYCLE_TOTAL_WL-1+1 || d1_counter == `CYCLE_TOTAL_WL-1+1 ||
				                        d2_counter == `CYCLE_TOTAL_WL-1+1 || d3_counter == `CYCLE_TOTAL_WL-1+1 ||
				                        d4_counter == `CYCLE_TOTAL_WL-1+1  )

				                  d_state_nxt = D_WRITE2 ;

				                else

				                  d_state_nxt = D_WAIT_CL_WRITE ;
		               end
		               else
                        //read
				                if(d0_counter == $unsigned(`CYCLE_TOTAL_RL-1+2) || d1_counter == $unsigned(`CYCLE_TOTAL_RL-1+2) ||
				                   d2_counter == $unsigned(`CYCLE_TOTAL_RL-1+2) || d3_counter == $unsigned(`CYCLE_TOTAL_RL-1+2) ||
				                   d4_counter == $unsigned(`CYCLE_TOTAL_RL-1+2)  )

				                  d_state_nxt = D_READ2 ;

				                else if(d0_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) || d1_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) ||
				                        d2_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) || d3_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) ||
				                        d4_counter == $unsigned(`CYCLE_TOTAL_RL-1+1)  )

				                  d_state_nxt = D_READ2 ;

				                else if(d0_counter == $unsigned(`CYCLE_TOTAL_RL-1 )|| d1_counter == $unsigned(`CYCLE_TOTAL_RL-1 )||
				                        d2_counter == $unsigned(`CYCLE_TOTAL_RL-1 )|| d3_counter == $unsigned(`CYCLE_TOTAL_RL-1 )||
				                        d4_counter == $unsigned(`CYCLE_TOTAL_RL-1  ))

				                  d_state_nxt = D_READ1 ;

				                else

				                  d_state_nxt = D_WAIT_CL_READ ;
		                 end

   default     : d_state_nxt = d_state ;
  endcase
end

//dq control state defination
always@* begin
  dq_state_nxt = dq_state ;
  case(dq_state)
   DQ_IDLE    : begin
                case(d_state)
                   D_WRITE1 : dq_state_nxt =DQ_OUT ;
                   D_WRITE2 : dq_state_nxt =DQ_OUT ;
                   D_WRITE_F : if(d0_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) || d1_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) ||
                                   d2_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) || d3_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) ||
                                   d4_counter == $unsigned(`CYCLE_TOTAL_WL-1-1))
                                  dq_state_nxt = DQ_IDLE ;
                                else if(d0_counter == $unsigned(`CYCLE_TOTAL_WL-1) || d1_counter ==$unsigned( `CYCLE_TOTAL_WL-1) ||
                                        d2_counter == $unsigned(`CYCLE_TOTAL_WL-1) || d3_counter == $unsigned(`CYCLE_TOTAL_WL-1) ||
                                        d4_counter == $unsigned(`CYCLE_TOTAL_WL-1))
                                  dq_state_nxt = DQ_OUT ;
                                else
                                  dq_state_nxt = DQ_IDLE ;

                   D_READ1 : dq_state_nxt = DQ_OUT ;
                   D_READ2 : dq_state_nxt = DQ_OUT ;
                   D_READ_F :if(d_state_nxt==D_WAIT_CL_WRITE || d_state_nxt==D_WAIT_CL_READ || d_state_nxt == D_IDLE)
                                dq_state_nxt = DQ_IDLE ;
                              else if(out_fifo_out[1]==1'b0)//write
                                dq_state_nxt = DQ_OUT ;
                              else if(d0_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) || d1_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) ||
	                                  d2_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) || d3_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) ||
	                                  d4_counter == $unsigned(`CYCLE_TOTAL_RL-1+1))
	                                  dq_state_nxt = DQ_OUT ;
	                               else
	                                  dq_state_nxt = DQ_IDLE ;

                   default : dq_state_nxt = DQ_IDLE ;
                 endcase
   end

   DQ_OUT     : begin
      if(d_state_nxt == D_WRITE_F)
	                   if(d0_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) || d1_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) ||
	                      d2_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) || d3_counter == $unsigned(`CYCLE_TOTAL_WL-1-1) ||
	                      d4_counter == $unsigned(`CYCLE_TOTAL_WL-1-1))
	                     dq_state_nxt = DQ_IDLE ;
	                   else if(d0_counter == $unsigned(`CYCLE_TOTAL_WL-1) || d1_counter == $unsigned(`CYCLE_TOTAL_WL-1) ||
	                           d2_counter == $unsigned(`CYCLE_TOTAL_WL-1) || d3_counter == $unsigned(`CYCLE_TOTAL_WL-1) ||
	                           d4_counter == $unsigned(`CYCLE_TOTAL_WL-1))
	                     dq_state_nxt = DQ_OUT ;
	                   else
	                     dq_state_nxt = DQ_IDLE ;

                 else if(d_state_nxt == D_READ_F)
                   	 if(d0_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) || d1_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) ||
	                      d2_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) || d3_counter == $unsigned(`CYCLE_TOTAL_RL-1+1) ||
	                      d4_counter == $unsigned(`CYCLE_TOTAL_RL-1+1))
                       dq_state_nxt = DQ_OUT ;
                     else
                       dq_state_nxt = DQ_IDLE ;
                 else
                   dq_state_nxt = DQ_OUT ;
   end

   default     : dq_state_nxt = dq_state ;
  endcase
end


//DDR3 rst control
always@* begin
  rst_n = (state == FSM_POWER_UP) ? (init_cnt >= 7) ? 0 : 1 : 1 ;
end

always_comb
begin: RECEIVE_WRITE_DATA
	WD = wdata_fifo_out ;
end

always@*
begin // From slower clk domain to faster one
  data_all_out_nxt = data_all_out;
	if(dq_state == DQ_OUT)
    if(W_BL==0)//Burst Length = 4
      data_all_out_nxt = (dq_counter <= 3) ? WD : {(8*`DQ_BITS-1){1'b0}} ;
    else//Burst_Length = 8
      data_all_out_nxt = (dq_counter <= 7) ? WD : {(8*`DQ_BITS-1){1'b0}} ;
  else
    data_all_out_nxt = WD ;
end

always@*
begin: D_COUNTER_USED_BLOCK

d_counter_used_end[0] = (d_counter_used[0]) ? (d0_counter > d1_counter &&
                                               d0_counter > d2_counter &&
                                               d0_counter > d3_counter &&
                                               d0_counter > d4_counter    ) ? 1'b0 : 1'b1 : 1'b0 ;

d_counter_used_end[1] = (d_counter_used[1]) ? (d1_counter > d0_counter &&
                                               d1_counter > d2_counter &&
                                               d1_counter > d3_counter &&
                                               d1_counter > d4_counter   ) ? 1'b0 : 1'b1 : 1'b0 ;

d_counter_used_end[2] = (d_counter_used[2]) ? (d2_counter > d0_counter &&
                                               d2_counter > d1_counter &&
                                               d2_counter > d3_counter &&
                                               d2_counter > d4_counter   ) ? 1'b0 : 1'b1 : 1'b0 ;

d_counter_used_end[3] = (d_counter_used[3]) ? (d3_counter > d0_counter &&
                                               d3_counter > d1_counter &&
                                               d3_counter > d2_counter &&
                                               d3_counter > d4_counter   ) ? 1'b0 : 1'b1 : 1'b0 ;

d_counter_used_end[4] = (d_counter_used[4]) ? (d4_counter > d0_counter &&
                                               d4_counter > d1_counter &&
                                               d4_counter > d2_counter &&
                                               d4_counter > d3_counter   ) ? 1'b0 : 1'b1 : 1'b0 ;


case(d_counter_used)
  5'b00000:d_counter_used_start = 5'b00001 ;
  5'b00001:d_counter_used_start = 5'b00011 ;
  5'b00010:d_counter_used_start = 5'b00011 ;
  5'b00011:d_counter_used_start = 5'b00111 ;
  5'b00100:d_counter_used_start = 5'b00101 ;
  5'b00101:d_counter_used_start = 5'b00111 ;
  5'b00110:d_counter_used_start = 5'b00111 ;
  5'b00111:d_counter_used_start = 5'b01111 ;
  5'b01000:d_counter_used_start = 5'b01001 ;
  5'b01001:d_counter_used_start = 5'b01011 ;
  5'b01010:d_counter_used_start = 5'b01011 ;
  5'b01011:d_counter_used_start = 5'b01111 ;
  5'b01100:d_counter_used_start = 5'b01101 ;
  5'b01101:d_counter_used_start = 5'b01111 ;
  5'b01110:d_counter_used_start = 5'b01111 ;
  5'b01111:d_counter_used_start = 5'b11111 ;
  5'b10000:d_counter_used_start = 5'b10001 ;
  5'b10001:d_counter_used_start = 5'b10011 ;
  5'b10010:d_counter_used_start = 5'b10011 ;
  5'b10011:d_counter_used_start = 5'b10111 ;
  5'b10100:d_counter_used_start = 5'b10101 ;
  5'b10101:d_counter_used_start = 5'b10111 ;
  5'b10110:d_counter_used_start = 5'b10111 ;
  5'b10111:d_counter_used_start = 5'b11111 ;
  5'b11000:d_counter_used_start = 5'b11001 ;
  5'b11001:d_counter_used_start = 5'b11011 ;
  5'b11010:d_counter_used_start = 5'b11011 ;
  5'b11011:d_counter_used_start = 5'b11111 ;
  5'b11100:d_counter_used_start = 5'b11101 ;
  5'b11101:d_counter_used_start = 5'b11111 ;
  5'b11110:d_counter_used_start = 5'b11111 ;
  default :d_counter_used_start = 5'b00000 ;
endcase




if( (d_state == D_WRITE2 && d_state_nxt == D_WRITE_F) ||
    (d_state == D_READ2  && d_state_nxt == D_READ_F)   )
    begin
    if(state == FSM_READ || state == FSM_WRITE) begin
    d_counter_used_nxt[0] = (d_counter_used[0]==0 && d_counter_used_start[0]==1) ? d_counter_used_start[0] : d_counter_used_end[0] ;
    d_counter_used_nxt[1] = (d_counter_used[1]==0 && d_counter_used_start[1]==1) ? d_counter_used_start[1] : d_counter_used_end[1] ;
    d_counter_used_nxt[2] = (d_counter_used[2]==0 && d_counter_used_start[2]==1) ? d_counter_used_start[2] : d_counter_used_end[2] ;
    d_counter_used_nxt[3] = (d_counter_used[3]==0 && d_counter_used_start[3]==1) ? d_counter_used_start[3] : d_counter_used_end[3] ;
    d_counter_used_nxt[4] = (d_counter_used[4]==0 && d_counter_used_start[4]==1) ? d_counter_used_start[4] : d_counter_used_end[4] ;
  end
  else
    d_counter_used_nxt = d_counter_used_end ;
end
else begin
	if(state == FSM_READ || state == FSM_WRITE)
    d_counter_used_nxt = d_counter_used_start ;
	else
	  d_counter_used_nxt = d_counter_used ;
end

end

//dqs control state init_cnt
always@* begin
 d0_counter_nxt = ( d_counter_used_nxt[0] ) ? d0_counter + 1 : 0 ;
 d1_counter_nxt = ( d_counter_used_nxt[1] ) ? d1_counter + 1 : 0 ;
 d2_counter_nxt = ( d_counter_used_nxt[2] ) ? d2_counter + 1 : 0 ;
 d3_counter_nxt = ( d_counter_used_nxt[3] ) ? d3_counter + 1 : 0 ;
 d4_counter_nxt = ( d_counter_used_nxt[4] ) ? d4_counter + 1 : 0 ;
end


//dq out init_cnt
always@* begin
	  case(dq_state)
	    DQ_OUT     : dq_counter_nxt = (dq_counter == process_BL) ? 0 : dq_counter + 1 ;
	    default     : dq_counter_nxt = 0 ;
	  endcase
end
//=======================================

// always@* begin
//   read_data = RD_buf_all;
// end

endmodule

module DW_fifo_s1_sf_inst(
    inst_clk, inst_rst_n, inst_push_req_n, inst_pop_req_n, inst_diag_n,
    inst_data_in, empty_inst, almost_empty_inst, half_full_inst,
    almost_full_inst, full_inst, error_inst, data_out_inst
);

    parameter width = 8;
    parameter depth = 4;
    parameter ae_level = 1;
    parameter af_level = 1;
    parameter err_mode = 0;
    parameter rst_mode = 0;

    input inst_clk;
    input inst_rst_n;
    input inst_push_req_n;
    input inst_pop_req_n;
    input inst_diag_n;
    input [width-1:0] inst_data_in;

    output empty_inst;
    output almost_empty_inst;
    output half_full_inst;
    output almost_full_inst;
    output full_inst;
    output error_inst;
    output [width-1:0] data_out_inst;

    // Instance of DW_fifo_s1_sf
    DW_fifo_s1_sf #(width, depth, ae_level, af_level, err_mode, rst_mode)
    U1 (
        .clk(inst_clk),
        .rst_n(inst_rst_n),
        .push_req_n(inst_push_req_n),
        .pop_req_n(inst_pop_req_n),
        .diag_n(inst_diag_n),
        .data_in(inst_data_in),
        .empty(empty_inst),
        .almost_empty(almost_empty_inst),
        .half_full(half_full_inst),
        .almost_full(almost_full_inst),
        .full(full_inst),
        .error(error_inst),
        .data_out(data_out_inst)
    );

endmodule
