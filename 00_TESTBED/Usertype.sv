`ifndef USERTYPE_SV
`define USERTYPE_SV

`include "define.sv"

package usertype;

typedef enum logic
		{ READ = 1,
		WRITE = 0 }
r_w_t;

// burst length
typedef enum logic{
	BL_4 = 0,
	BL_8 = 1
} bl_t;

typedef struct packed {
		r_w_t r_w; //0:write, 1:read
		logic none_0; //reserved
		logic[`ROW_BITS-1:0] row_addr; //row address
		logic none_1; //reserved
		bl_t burst_length; //burst length
		logic none_2; //reserved
		logic auto_precharge; //auto precharge
		logic[`COL_BITS-1:0] col_addr; //column address
		logic[`BA_BITS-1:0] bank_addr; //bank address
	} command_t;

typedef struct packed {
    logic[1:0] rank_num; // rank number 2
    r_w_t r_w; //0:write, 1:read 1
		logic none_0; //reserved 1
		logic[`ROW_BITS-1:0] row_addr; //row address
		logic none_1; //reserved
		bl_t burst_length; //burst length
		logic none_2; //reserved
		logic auto_precharge; //auto precharge
		logic[`COL_BITS-1:0] col_addr; //column address
		logic[`BA_BITS-1:0] bank_addr; //bank address
} user_command_type_t;

typedef enum logic[`FSM_WIDTH1-1:0]{
  FSM_POWER_UP,
  FSM_WAIT_TXPR,
  FSM_ZQ,
  FSM_LMR0,
  FSM_LMR1,
  FSM_LMR2,
  FSM_LMR3,
  FSM_WAIT_TMRD,
  FSM_WAIT_TDLLK,
  FSM_IDLE,
  FSM_READY,
  FSM_ACTIVE,
  FSM_POWER_D,
  FSM_REFRESH,
  FSM_REFRESHING,
  FSM_WRITE,
  FSM_READ,
  FSM_PRE,
  FSM_WAIT_TRRD,
  FSM_WAIT_TCCD,
  FSM_DLY_WRITE,
  FSM_DLY_READ,
  FSM_WAIT_TRCD,
  FSM_WAIT_TRTW,
  FSM_WAIT_OUT_F,
  FSM_WAIT_TWTR,
  FSM_WAIT_TRTP,
  FSM_WAIT_TWR,
  FSM_WAIT_TRP,
  FSM_WAIT_TRAS,
  FSM_WAIT_TRC,
  FSM_READA,
  FSM_WRITEA,
  FSM_PREA
} main_state_t;

typedef enum logic[`FSM_WIDTH3-1:0]{
  D_IDLE,
  D_WAIT_CL_WRITE,
  D_WAIT_CL_READ,
  D_WRITE1,
  D_WRITE2,
  D_WRITE_F,
  D_READ1,
  D_READ2,
  D_READ_F
} d_state_t;


typedef enum logic[4:0]{
  DQ_IDLE,
  DQ_WAIT_CL_WRITE,
  DQ_WAIT_CL_READ,
  DQ_WRITE1,
  DQ_WRITE2,
  DQ_WRITE_F,
  DQ_READ1,
  DQ_READ2,
  DQ_READ_F,
  DQ_OUT
} dq_state_t;


typedef enum logic[`FSM_WIDTH2-1:0] {
  B_INITIAL,
  B_IDLE,
  B_ACTIVE,
  B_ACT_CHECK,
  B_WRITE,
  B_READ,
  B_WRITE_CHECK,
  B_READ_CHECK,
  B_PRE,
  B_PRE_CHECK,
  B_ACT_STANDBY,
  B_REFRESH_CHECK,
  B_WAIT_ISSUE_REFRESH,
  B_REFRESHING,
  B_ISSUE_REFRESH,
  B_READA,
  B_WRITEA,
  B_PREA
} bank_state_t;

typedef enum logic [2:0] {
  PROC_NO = 0,
  PROC_READ = 2,
  PROC_WRITE = 1
 } process_cmd_t;

 typedef enum logic [3:0] {
  ATCMD_NOP,
  ATCMD_READ,
  ATCMD_WRITE,
  ATCMD_POWER_D,
  ATCMD_POWER_U,
  ATCMD_REFRESH,
  ATCMD_ACTIVE,
  ATCMD_PRECHARGE,
  ATCMD_RDA,
  ATCMD_WRA,
  ATCMD_PREA
 } sch_cmd_t;

 typedef struct packed {
  bank_state_t bank_state;
  logic[`ADDR_BITS-1:0] addr;
  process_cmd_t proc_cmd;
 } bank_info_t;


 typedef struct packed {
  sch_cmd_t command;
  logic[`COL_BITS+`ROW_BITS-1:0] addr;
} issue_fifo_cmd_in_t;

typedef enum logic[2:0] {
  CODE_IDLE = 0,
  CODE_WRITE_TO_PRECHARGE = 1,
  CODE_PRECHARGE_TO_ACTIVE = 2,
  CODE_ACTIVE_TO_READ_WRITE = 3,
  CODE_READ_TO_PRECHARGE = 4,
  CODE_WRITE_TO_ACTIVE = 5,
  CODE_READ_TO_ACTIVE = 6,
  CODE_PRECHARGE_TO_REFRESH = 7
 } recode_state_t;

endpackage

import usertype::*;

`endif