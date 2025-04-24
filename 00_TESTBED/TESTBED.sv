`timescale 1ns / 10ps
`include "frontend_cmd_definition_pkg.sv"
`include "PATTERN.sv"

`ifdef RTL
    `include "Global_Controller.sv"
    `include "Backend_Controller.sv"
    `include "MEM_PAD.sv"
    `include "ddr3.sv"
`endif
`ifdef GATE
    `include "Global_Controller_SYN.sv"
    `include "Backend_Controller_SYN.sv"
    `include "MEM_PAD.sv"
    `include "ddr3.sv"
`endif

module TESTBED;

`include "2048Mb_ddr3_parameters.vh"

initial begin
    `ifdef RTL
        $fsdbDumpfile("Global_Controller.fsdb");
        $fsdbDumpvars(0,"+all");
        $fsdbDumpSVA;
    `endif
    `ifdef GATE
        $sdf_annotate("Global_Controller_SYN.sdf", I_Global_Controller);
        $fsdbDumpfile("Global_Controller_SYN.fsdb");
        $fsdbDumpvars(0,"+all");
        $fsdbDumpSVA;
    `endif
end

logic clk;
logic clk2;
logic rst_n;

// Global Controller Signals(Core-GC/ GC-BC0/ GC-BC1/ GC-BC2/ GC-BC3)
logic core_command_valid;
frontend_command_t core_command;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] core_write_data;
logic controller_ready;

logic read_data_valid;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] read_data;

logic backend_controller_ready_bc0;
logic backend_controller_ready_bc1;
logic backend_controller_ready_bc2;
logic backend_controller_ready_bc3;

logic frontend_command_valid_bc0;
logic frontend_command_valid_bc1;
logic frontend_command_valid_bc2;
logic frontend_command_valid_bc3;

backend_command_t frontend_command_bc0;
backend_command_t frontend_command_bc1;
backend_command_t frontend_command_bc2;
backend_command_t frontend_command_bc3;

logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] frontend_write_data_bc0;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] frontend_write_data_bc1;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] frontend_write_data_bc2;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] frontend_write_data_bc3;

logic backend_controller_ren_bc0;
logic backend_controller_ren_bc1;
logic backend_controller_ren_bc2;
logic backend_controller_ren_bc3;

logic returned_data_valid_bc0;
logic returned_data_valid_bc1;
logic returned_data_valid_bc2;
logic returned_data_valid_bc3;

logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] returned_data_bc0;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] returned_data_bc1;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] returned_data_bc2;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] returned_data_bc3;

// Backend Controller to DDR3/MEM Signals
// Declare DDR3 signals for each backend controller
wire                ddr3_rst_n_bc0       ;
wire                ddr3_rst_n_bc1       ;
wire                ddr3_rst_n_bc2       ;
wire                ddr3_rst_n_bc3       ;

wire                ddr3_cke_bc0         ;
wire                ddr3_cke_bc1         ;
wire                ddr3_cke_bc2         ;
wire                ddr3_cke_bc3         ;

wire                ddr3_cs_n_bc0        ;
wire                ddr3_cs_n_bc1        ;
wire                ddr3_cs_n_bc2        ;
wire                ddr3_cs_n_bc3        ;

wire                ddr3_ras_n_bc0       ;
wire                ddr3_ras_n_bc1       ;
wire                ddr3_ras_n_bc2       ;
wire                ddr3_ras_n_bc3       ;

wire                ddr3_cas_n_bc0       ;
wire                ddr3_cas_n_bc1       ;
wire                ddr3_cas_n_bc2       ;
wire                ddr3_cas_n_bc3       ;

wire                ddr3_we_n_bc0        ;
wire                ddr3_we_n_bc1        ;
wire                ddr3_we_n_bc2        ;
wire                ddr3_we_n_bc3        ;

wire [`DM_BITS-1:0] ddr3_dm_tdqs_in_bc0  ;
wire [`DM_BITS-1:0] ddr3_dm_tdqs_in_bc1  ;
wire [`DM_BITS-1:0] ddr3_dm_tdqs_in_bc2  ;
wire [`DM_BITS-1:0] ddr3_dm_tdqs_in_bc3  ;

wire [`DM_BITS-1:0] ddr3_dm_tdqs_out_bc0 ;
wire [`DM_BITS-1:0] ddr3_dm_tdqs_out_bc1 ;
wire [`DM_BITS-1:0] ddr3_dm_tdqs_out_bc2 ;
wire [`DM_BITS-1:0] ddr3_dm_tdqs_out_bc3 ;

wire [`BA_BITS-1:0] ddr3_ba_bc0          ;
wire [`BA_BITS-1:0] ddr3_ba_bc1          ;
wire [`BA_BITS-1:0] ddr3_ba_bc2          ;
wire [`BA_BITS-1:0] ddr3_ba_bc3          ;

wire [`ADDR_BITS-1:0] ddr3_addr_bc0      ;
wire [`ADDR_BITS-1:0] ddr3_addr_bc1      ;
wire [`ADDR_BITS-1:0] ddr3_addr_bc2      ;
wire [`ADDR_BITS-1:0] ddr3_addr_bc3      ;

wire [`DQ_BITS-1:0] ddr3_data_in_bc0     ;
wire [`DQ_BITS-1:0] ddr3_data_in_bc1     ;
wire [`DQ_BITS-1:0] ddr3_data_in_bc2     ;
wire [`DQ_BITS-1:0] ddr3_data_in_bc3     ;

wire [`DQ_BITS-1:0] ddr3_data_out_bc0    ;
wire [`DQ_BITS-1:0] ddr3_data_out_bc1    ;
wire [`DQ_BITS-1:0] ddr3_data_out_bc2    ;
wire [`DQ_BITS-1:0] ddr3_data_out_bc3    ;

wire [`DQ_BITS*8-1:0] ddr3_data_all_in_bc0 ;
wire [`DQ_BITS*8-1:0] ddr3_data_all_in_bc1 ;
wire [`DQ_BITS*8-1:0] ddr3_data_all_in_bc2 ;
wire [`DQ_BITS*8-1:0] ddr3_data_all_in_bc3 ;

wire [`DQ_BITS*8-1:0] ddr3_data_all_out_bc0;
wire [`DQ_BITS*8-1:0] ddr3_data_all_out_bc1;
wire [`DQ_BITS*8-1:0] ddr3_data_all_out_bc2;
wire [`DQ_BITS*8-1:0] ddr3_data_all_out_bc3;

wire [`DQS_BITS-1:0] ddr3_dqs_in_bc0     ;
wire [`DQS_BITS-1:0] ddr3_dqs_in_bc1     ;
wire [`DQS_BITS-1:0] ddr3_dqs_in_bc2     ;
wire [`DQS_BITS-1:0] ddr3_dqs_in_bc3     ;

wire [`DQS_BITS-1:0] ddr3_dqs_out_bc0    ;
wire [`DQS_BITS-1:0] ddr3_dqs_out_bc1    ;
wire [`DQS_BITS-1:0] ddr3_dqs_out_bc2    ;
wire [`DQS_BITS-1:0] ddr3_dqs_out_bc3    ;

wire [`DQS_BITS-1:0] ddr3_dqs_n_in_bc0   ;
wire [`DQS_BITS-1:0] ddr3_dqs_n_in_bc1   ;
wire [`DQS_BITS-1:0] ddr3_dqs_n_in_bc2   ;
wire [`DQS_BITS-1:0] ddr3_dqs_n_in_bc3   ;

wire [`DQS_BITS-1:0] ddr3_dqs_n_out_bc0  ;
wire [`DQS_BITS-1:0] ddr3_dqs_n_out_bc1  ;
wire [`DQS_BITS-1:0] ddr3_dqs_n_out_bc2  ;
wire [`DQS_BITS-1:0] ddr3_dqs_n_out_bc3  ;

wire [`DQS_BITS-1:0] ddr3_tdqs_n_bc0     ;
wire [`DQS_BITS-1:0] ddr3_tdqs_n_bc1     ;
wire [`DQS_BITS-1:0] ddr3_tdqs_n_bc2     ;
wire [`DQS_BITS-1:0] ddr3_tdqs_n_bc3     ;

wire ddr3_odt_bc0                        ;
wire ddr3_odt_bc1                        ;
wire ddr3_odt_bc2                        ;
wire ddr3_odt_bc3                        ;

wire ddr3_rw_bc0                         ;
wire ddr3_rw_bc1                         ;
wire ddr3_rw_bc2                         ;
wire ddr3_rw_bc3                         ;

// Declare MEM_PAD signals for each backend controller
wire pad_rst_n_bc0;
wire pad_rst_n_bc1;
wire pad_rst_n_bc2;
wire pad_rst_n_bc3;

wire pad_cke_bc0;
wire pad_cke_bc1;
wire pad_cke_bc2;
wire pad_cke_bc3;

wire pad_cs_n_bc0;
wire pad_cs_n_bc1;
wire pad_cs_n_bc2;
wire pad_cs_n_bc3;

wire pad_ras_n_bc0;
wire pad_ras_n_bc1;
wire pad_ras_n_bc2;
wire pad_ras_n_bc3;

wire pad_cas_n_bc0;
wire pad_cas_n_bc1;
wire pad_cas_n_bc2;
wire pad_cas_n_bc3;

wire pad_we_n_bc0;
wire pad_we_n_bc1;
wire pad_we_n_bc2;
wire pad_we_n_bc3;

wire [`DQS_BITS-1:0] pad_dm_tdqs_bc0;
wire [`DQS_BITS-1:0] pad_dm_tdqs_bc1;
wire [`DQS_BITS-1:0] pad_dm_tdqs_bc2;
wire [`DQS_BITS-1:0] pad_dm_tdqs_bc3;

wire [`BA_BITS-1:0] pad_ba_bc0;
wire [`BA_BITS-1:0] pad_ba_bc1;
wire [`BA_BITS-1:0] pad_ba_bc2;
wire [`BA_BITS-1:0] pad_ba_bc3;

wire [`ADDR_BITS-1:0] pad_addr_bc0;
wire [`ADDR_BITS-1:0] pad_addr_bc1;
wire [`ADDR_BITS-1:0] pad_addr_bc2;
wire [`ADDR_BITS-1:0] pad_addr_bc3;

wire [`DQ_BITS-1:0] pad_dq_bc0;
wire [`DQ_BITS-1:0] pad_dq_bc1;
wire [`DQ_BITS-1:0] pad_dq_bc2;
wire [`DQ_BITS-1:0] pad_dq_bc3;

wire [`DQ_BITS*8-1:0] pad_dq_all_bc0;
wire [`DQ_BITS*8-1:0] pad_dq_all_bc1;
wire [`DQ_BITS*8-1:0] pad_dq_all_bc2;
wire [`DQ_BITS*8-1:0] pad_dq_all_bc3;

wire [`DQS_BITS-1:0] pad_dqs_bc0;
wire [`DQS_BITS-1:0] pad_dqs_bc1;
wire [`DQS_BITS-1:0] pad_dqs_bc2;
wire [`DQS_BITS-1:0] pad_dqs_bc3;

wire [`DQS_BITS-1:0] pad_dqs_n_bc0;
wire [`DQS_BITS-1:0] pad_dqs_n_bc1;
wire [`DQS_BITS-1:0] pad_dqs_n_bc2;
wire [`DQS_BITS-1:0] pad_dqs_n_bc3;

wire [`DQS_BITS-1:0] pad_tdqs_n_bc0;
wire [`DQS_BITS-1:0] pad_tdqs_n_bc1;
wire [`DQS_BITS-1:0] pad_tdqs_n_bc2;
wire [`DQS_BITS-1:0] pad_tdqs_n_bc3;

wire pad_odt_bc0;
wire pad_odt_bc1;
wire pad_odt_bc2;
wire pad_odt_bc3;

wire pad_ck_bc0;
wire pad_ck_bc1;
wire pad_ck_bc2;
wire pad_ck_bc3;

wire pad_ck_n_bc0;
wire pad_ck_n_bc1;
wire pad_ck_n_bc2;
wire pad_ck_n_bc3;

// Instantiate the Global Controller module
Global_Controller I_Global_Controller (
    .i_clk(clk),
    .i_rst_n(rst_n),

    .i_command_valid(core_command_valid),
    .i_command(core_command),
    .i_write_data(core_write_data),
    .o_controller_ready(controller_ready),

    .o_read_data_valid(read_data_valid),
    .o_read_data(read_data),

    .i_backend_controller_ready_bc0(backend_controller_ready_bc0),
    .i_backend_controller_ready_bc1(backend_controller_ready_bc1),
    .i_backend_controller_ready_bc2(backend_controller_ready_bc2),
    .i_backend_controller_ready_bc3(backend_controller_ready_bc3),

    .o_frontend_command_valid_bc0(frontend_command_valid_bc0),
    .o_frontend_command_valid_bc1(frontend_command_valid_bc1),
    .o_frontend_command_valid_bc2(frontend_command_valid_bc2),
    .o_frontend_command_valid_bc3(frontend_command_valid_bc3),

    .o_frontend_command_bc0(frontend_command_bc0),
    .o_frontend_command_bc1(frontend_command_bc1),
    .o_frontend_command_bc2(frontend_command_bc2),
    .o_frontend_command_bc3(frontend_command_bc3),

    .o_frontend_write_data_bc0(frontend_write_data_bc0),
    .o_frontend_write_data_bc1(frontend_write_data_bc1),
    .o_frontend_write_data_bc2(frontend_write_data_bc2),
    .o_frontend_write_data_bc3(frontend_write_data_bc3),

    .o_backend_controller_ren_bc0(backend_controller_ren_bc0),
    .o_backend_controller_ren_bc1(backend_controller_ren_bc1),
    .o_backend_controller_ren_bc2(backend_controller_ren_bc2),
    .o_backend_controller_ren_bc3(backend_controller_ren_bc3),

    .i_returned_data_valid_bc0(returned_data_valid_bc0),
    .i_returned_data_valid_bc1(returned_data_valid_bc1),
    .i_returned_data_valid_bc2(returned_data_valid_bc2),
    .i_returned_data_valid_bc3(returned_data_valid_bc3),

    .i_returned_data_bc0(returned_data_bc0),
    .i_returned_data_bc1(returned_data_bc1),
    .i_returned_data_bc2(returned_data_bc2),
    .i_returned_data_bc3(returned_data_bc3)
);

// Instantiate 4 Backend Controllers
// Instantiate Backend Controller 0
Backend_Controller I_BackendController_0(
//== I/O from System ===============
         .power_on_rst_n(rst_n),
         .clk           (clk  ),
         .clk2          (clk2 ),
//==================================

//== I/O from access command ========================================
//Command Channel
         .o_backend_controller_ready(backend_controller_ready_bc0),
         .i_frontend_write_data     (frontend_write_data_bc0     ),
         .i_frontend_command_valid  (frontend_command_valid_bc0  ),
         .i_frontend_command        (frontend_command_bc0        ),
//Returned data channel
         .o_backend_read_data       (returned_data_bc0      ),
         .o_backend_read_data_valid (returned_data_valid_bc0),
         .i_backend_controller_ren  (backend_controller_ren_bc0),
//===================================================================
//=== I/O from pad interface ======
         .rst_n       (ddr3_rst_n_bc0      ),
         .cke         (ddr3_cke_bc0        ),
         .cs_n        (ddr3_cs_n_bc0       ),
         .ras_n       (ddr3_ras_n_bc0      ),
         .cas_n       (ddr3_cas_n_bc0      ),
         .we_n        (ddr3_we_n_bc0       ),
         .dm_tdqs_in  (ddr3_dm_tdqs_in_bc0 ),
         .dm_tdqs_out (ddr3_dm_tdqs_out_bc0),
         .ba          (ddr3_ba_bc0         ),
         .addr        (ddr3_addr_bc0       ),
         .data_in     (ddr3_data_in_bc0    ),
         .data_out    (ddr3_data_out_bc0   ),
         .data_all_in (ddr3_data_all_in_bc0),
         .data_all_out(ddr3_data_all_out_bc0),
         .dqs_in      (ddr3_dqs_in_bc0     ),
         .dqs_out     (ddr3_dqs_out_bc0    ),
         .dqs_n_in    (ddr3_dqs_n_in_bc0   ),
         .dqs_n_out   (ddr3_dqs_n_out_bc0  ),
         .tdqs_n      (ddr3_tdqs_n_bc0     ),
         .odt         (ddr3_odt_bc0        ),
         .ddr3_rw     (ddr3_rw_bc0         )
);

// Instantiate Backend Controller 1
Backend_Controller I_BackendController_1(
//== I/O from System ===============
         .power_on_rst_n(rst_n),
         .clk           (clk  ),
         .clk2          (clk2 ),
//==================================

//== I/O from access command ========================================
//Command Channel
         .o_backend_controller_ready(backend_controller_ready_bc1),
         .i_frontend_write_data     (frontend_write_data_bc1     ),
         .i_frontend_command_valid  (frontend_command_valid_bc1  ),
         .i_frontend_command        (frontend_command_bc1        ),
//Returned data channel
         .o_backend_read_data       (returned_data_bc1      ),
         .o_backend_read_data_valid (returned_data_valid_bc1),
         .i_backend_controller_ren  (backend_controller_ren_bc1),
//===================================================================
//=== I/O from pad interface ======
         .rst_n       (ddr3_rst_n_bc1      ),
         .cke         (ddr3_cke_bc1        ),
         .cs_n        (ddr3_cs_n_bc1       ),
         .ras_n       (ddr3_ras_n_bc1      ),
         .cas_n       (ddr3_cas_n_bc1      ),
         .we_n        (ddr3_we_n_bc1       ),
         .dm_tdqs_in  (ddr3_dm_tdqs_in_bc1 ),
         .dm_tdqs_out (ddr3_dm_tdqs_out_bc1),
         .ba          (ddr3_ba_bc1         ),
         .addr        (ddr3_addr_bc1       ),
         .data_in     (ddr3_data_in_bc1    ),
         .data_out    (ddr3_data_out_bc1   ),
         .data_all_in (ddr3_data_all_in_bc1),
         .data_all_out(ddr3_data_all_out_bc1),
         .dqs_in      (ddr3_dqs_in_bc1     ),
         .dqs_out     (ddr3_dqs_out_bc1    ),
         .dqs_n_in    (ddr3_dqs_n_in_bc1   ),
         .dqs_n_out   (ddr3_dqs_n_out_bc1  ),
         .tdqs_n      (ddr3_tdqs_n_bc1     ),
         .odt         (ddr3_odt_bc1        ),
         .ddr3_rw     (ddr3_rw_bc1         )
);

// Instantiate Backend Controller 2
Backend_Controller I_BackendController_2(
//== I/O from System ===============
         .power_on_rst_n(rst_n),
         .clk           (clk  ),
         .clk2          (clk2 ),
//==================================

//== I/O from access command ========================================
//Command Channel
         .o_backend_controller_ready(backend_controller_ready_bc2),
         .i_frontend_write_data     (frontend_write_data_bc2     ),
         .i_frontend_command_valid  (frontend_command_valid_bc2  ),
         .i_frontend_command        (frontend_command_bc2        ),
//Returned data channel
         .o_backend_read_data       (returned_data_bc2      ),
         .o_backend_read_data_valid (returned_data_valid_bc2),
         .i_backend_controller_ren  (backend_controller_ren_bc2),
//===================================================================
//=== I/O from pad interface ======
         .rst_n       (ddr3_rst_n_bc2      ),
         .cke         (ddr3_cke_bc2        ),
         .cs_n        (ddr3_cs_n_bc2       ),
         .ras_n       (ddr3_ras_n_bc2      ),
         .cas_n       (ddr3_cas_n_bc2      ),
         .we_n        (ddr3_we_n_bc2       ),
         .dm_tdqs_in  (ddr3_dm_tdqs_in_bc2 ),
         .dm_tdqs_out (ddr3_dm_tdqs_out_bc2),
         .ba          (ddr3_ba_bc2         ),
         .addr        (ddr3_addr_bc2       ),
         .data_in     (ddr3_data_in_bc2    ),
         .data_out    (ddr3_data_out_bc2   ),
         .data_all_in (ddr3_data_all_in_bc2),
         .data_all_out(ddr3_data_all_out_bc2),
         .dqs_in      (ddr3_dqs_in_bc2     ),
         .dqs_out     (ddr3_dqs_out_bc2    ),
         .dqs_n_in    (ddr3_dqs_n_in_bc2   ),
         .dqs_n_out   (ddr3_dqs_n_out_bc2  ),
         .tdqs_n      (ddr3_tdqs_n_bc2     ),
         .odt         (ddr3_odt_bc2        ),
         .ddr3_rw     (ddr3_rw_bc2         )
);

// Instantiate Backend Controller 3
Backend_Controller I_BackendController_3(
//== I/O from System ===============
         .power_on_rst_n(rst_n),
         .clk           (clk  ),
         .clk2          (clk2 ),
//==================================

//== I/O from access command ========================================
//Command Channel
         .o_backend_controller_ready(backend_controller_ready_bc3),
         .i_frontend_write_data     (frontend_write_data_bc3     ),
         .i_frontend_command_valid  (frontend_command_valid_bc3  ),
         .i_frontend_command        (frontend_command_bc3        ),
//Returned data channel
         .o_backend_read_data       (returned_data_bc3      ),
         .o_backend_read_data_valid (returned_data_valid_bc3),
         .i_backend_controller_ren  (backend_controller_ren_bc3),
//===================================================================
//=== I/O from pad interface ======
         .rst_n       (ddr3_rst_n_bc3      ),
         .cke         (ddr3_cke_bc3        ),
         .cs_n        (ddr3_cs_n_bc3       ),
         .ras_n       (ddr3_ras_n_bc3      ),
         .cas_n       (ddr3_cas_n_bc3      ),
         .we_n        (ddr3_we_n_bc3       ),
         .dm_tdqs_in  (ddr3_dm_tdqs_in_bc3 ),
         .dm_tdqs_out (ddr3_dm_tdqs_out_bc3),
         .ba          (ddr3_ba_bc3         ),
         .addr        (ddr3_addr_bc3       ),
         .data_in     (ddr3_data_in_bc3    ),
         .data_out    (ddr3_data_out_bc3   ),
         .data_all_in (ddr3_data_all_in_bc3),
         .data_all_out(ddr3_data_all_out_bc3),
         .dqs_in      (ddr3_dqs_in_bc3     ),
         .dqs_out     (ddr3_dqs_out_bc3    ),
         .dqs_n_in    (ddr3_dqs_n_in_bc3   ),
         .dqs_n_out   (ddr3_dqs_n_out_bc3  ),
         .tdqs_n      (ddr3_tdqs_n_bc3     ),
         .odt         (ddr3_odt_bc3        ),
         .ddr3_rw     (ddr3_rw_bc3         )
);

// Instantiate 4 MEM_PADs
// Instantiate MEM_PAD 0
MEM_PAD I_MEM_PAD_0(
    //== I/O for Controller ===============
         .ddr3_rst_n       (ddr3_rst_n_bc0      ),
         .ddr3_cke         (ddr3_cke_bc0        ),
         .ddr3_cs_n        (ddr3_cs_n_bc0       ),
         .ddr3_ras_n       (ddr3_ras_n_bc0      ),
         .ddr3_cas_n       (ddr3_cas_n_bc0      ),
         .ddr3_we_n        (ddr3_we_n_bc0       ),
         .ddr3_dm_tdqs_in  (ddr3_dm_tdqs_in_bc0 ),
         .ddr3_dm_tdqs_out (ddr3_dm_tdqs_out_bc0),
         .ddr3_ba          (ddr3_ba_bc0         ),
         .ddr3_addr        (ddr3_addr_bc0       ),
         .ddr3_data_in     (ddr3_data_in_bc0    ),
         .ddr3_data_out    (ddr3_data_out_bc0   ),
         .ddr3_data_all_in (ddr3_data_all_in_bc0),
         .ddr3_data_all_out(ddr3_data_all_out_bc0),
         .ddr3_dqs_in      (ddr3_dqs_in_bc0     ),
         .ddr3_dqs_out     (ddr3_dqs_out_bc0    ),
         .ddr3_dqs_n_in    (ddr3_dqs_n_in_bc0   ),
         .ddr3_dqs_n_out   (ddr3_dqs_n_out_bc0  ),
         .ddr3_tdqs_n      (ddr3_tdqs_n_bc0     ),
         .ddr3_odt         (ddr3_odt_bc0        ),
         .ddr3_rw          (ddr3_rw_bc0         ),
         .ddr3_ck          (clk                 ),

    //== I/O for ddr3 =====================
         .pad_rst_n        (pad_rst_n_bc0       ),
         .pad_cke          (pad_cke_bc0         ),
         .pad_cs_n         (pad_cs_n_bc0        ),
         .pad_ras_n        (pad_ras_n_bc0       ),
         .pad_cas_n        (pad_cas_n_bc0       ),
         .pad_we_n         (pad_we_n_bc0        ),
         .pad_dm_tdqs      (pad_dm_tdqs_bc0     ),
         .pad_ba           (pad_ba_bc0          ),
         .pad_addr         (pad_addr_bc0        ),
         .pad_dq           (pad_dq_bc0          ),
         .pad_dqs          (pad_dqs_bc0         ),
         .pad_dqs_n        (pad_dqs_n_bc0       ),
         .pad_tdqs_n       (pad_tdqs_n_bc0      ),
         .pad_odt          (pad_odt_bc0         ),
         .pad_ck           (pad_ck_bc0          ),
         .pad_ck_n         (pad_ck_n_bc0        ),
         .pad_dq_all       (pad_dq_all_bc0      )
);

// Instantiate MEM_PAD 1
MEM_PAD I_MEM_PAD_1(
    //== I/O for Controller ===============
         .ddr3_rst_n       (ddr3_rst_n_bc1      ),
         .ddr3_cke         (ddr3_cke_bc1        ),
         .ddr3_cs_n        (ddr3_cs_n_bc1       ),
         .ddr3_ras_n       (ddr3_ras_n_bc1      ),
         .ddr3_cas_n       (ddr3_cas_n_bc1      ),
         .ddr3_we_n        (ddr3_we_n_bc1       ),
         .ddr3_dm_tdqs_in  (ddr3_dm_tdqs_in_bc1 ),
         .ddr3_dm_tdqs_out (ddr3_dm_tdqs_out_bc1),
         .ddr3_ba          (ddr3_ba_bc1         ),
         .ddr3_addr        (ddr3_addr_bc1       ),
         .ddr3_data_in     (ddr3_data_in_bc1    ),
         .ddr3_data_out    (ddr3_data_out_bc1   ),
         .ddr3_data_all_in (ddr3_data_all_in_bc1),
         .ddr3_data_all_out(ddr3_data_all_out_bc1),
         .ddr3_dqs_in      (ddr3_dqs_in_bc1     ),
         .ddr3_dqs_out     (ddr3_dqs_out_bc1    ),
         .ddr3_dqs_n_in    (ddr3_dqs_n_in_bc1   ),
         .ddr3_dqs_n_out   (ddr3_dqs_n_out_bc1  ),
         .ddr3_tdqs_n      (ddr3_tdqs_n_bc1     ),
         .ddr3_odt         (ddr3_odt_bc1        ),
         .ddr3_rw          (ddr3_rw_bc1         ),
         .ddr3_ck          (clk                 ),

    //== I/O for ddr3 =====================
         .pad_rst_n        (pad_rst_n_bc1       ),
         .pad_cke          (pad_cke_bc1         ),
         .pad_cs_n         (pad_cs_n_bc1        ),
         .pad_ras_n        (pad_ras_n_bc1       ),
         .pad_cas_n        (pad_cas_n_bc1       ),
         .pad_we_n         (pad_we_n_bc1        ),
         .pad_dm_tdqs      (pad_dm_tdqs_bc1     ),
         .pad_ba           (pad_ba_bc1          ),
         .pad_addr         (pad_addr_bc1        ),
         .pad_dq           (pad_dq_bc1          ),
         .pad_dqs          (pad_dqs_bc1         ),
         .pad_dqs_n        (pad_dqs_n_bc1       ),
         .pad_tdqs_n       (pad_tdqs_n_bc1      ),
         .pad_odt          (pad_odt_bc1         ),
         .pad_ck           (pad_ck_bc1          ),
         .pad_ck_n         (pad_ck_n_bc1        ),
         .pad_dq_all       (pad_dq_all_bc1      )
);

// Instantiate MEM_PAD 2
MEM_PAD I_MEM_PAD_2(
    //== I/O for Controller ===============
         .ddr3_rst_n       (ddr3_rst_n_bc2      ),
         .ddr3_cke         (ddr3_cke_bc2        ),
         .ddr3_cs_n        (ddr3_cs_n_bc2       ),
         .ddr3_ras_n       (ddr3_ras_n_bc2      ),
         .ddr3_cas_n       (ddr3_cas_n_bc2      ),
         .ddr3_we_n        (ddr3_we_n_bc2       ),
         .ddr3_dm_tdqs_in  (ddr3_dm_tdqs_in_bc2 ),
         .ddr3_dm_tdqs_out (ddr3_dm_tdqs_out_bc2),
         .ddr3_ba          (ddr3_ba_bc2         ),
         .ddr3_addr        (ddr3_addr_bc2       ),
         .ddr3_data_in     (ddr3_data_in_bc2    ),
         .ddr3_data_out    (ddr3_data_out_bc2   ),
         .ddr3_data_all_in (ddr3_data_all_in_bc2),
         .ddr3_data_all_out(ddr3_data_all_out_bc2),
         .ddr3_dqs_in      (ddr3_dqs_in_bc2     ),
         .ddr3_dqs_out     (ddr3_dqs_out_bc2    ),
         .ddr3_dqs_n_in    (ddr3_dqs_n_in_bc2   ),
         .ddr3_dqs_n_out   (ddr3_dqs_n_out_bc2  ),
         .ddr3_tdqs_n      (ddr3_tdqs_n_bc2     ),
         .ddr3_odt         (ddr3_odt_bc2        ),
         .ddr3_rw          (ddr3_rw_bc2         ),
         .ddr3_ck          (clk                 ),

    //== I/O for ddr3 =====================
         .pad_rst_n        (pad_rst_n_bc2       ),
         .pad_cke          (pad_cke_bc2         ),
         .pad_cs_n         (pad_cs_n_bc2        ),
         .pad_ras_n        (pad_ras_n_bc2       ),
         .pad_cas_n        (pad_cas_n_bc2       ),
         .pad_we_n         (pad_we_n_bc2        ),
         .pad_dm_tdqs      (pad_dm_tdqs_bc2     ),
         .pad_ba           (pad_ba_bc2          ),
         .pad_addr         (pad_addr_bc2        ),
         .pad_dq           (pad_dq_bc2          ),
         .pad_dqs          (pad_dqs_bc2         ),
         .pad_dqs_n        (pad_dqs_n_bc2       ),
         .pad_tdqs_n       (pad_tdqs_n_bc2      ),
         .pad_odt          (pad_odt_bc2         ),
         .pad_ck           (pad_ck_bc2          ),
         .pad_ck_n         (pad_ck_n_bc2        ),
         .pad_dq_all       (pad_dq_all_bc2      )
);

// Instantiate MEM_PAD 3
MEM_PAD I_MEM_PAD_3(
    //== I/O for Controller ===============
         .ddr3_rst_n       (ddr3_rst_n_bc3      ),
         .ddr3_cke         (ddr3_cke_bc3        ),
         .ddr3_cs_n        (ddr3_cs_n_bc3       ),
         .ddr3_ras_n       (ddr3_ras_n_bc3      ),
         .ddr3_cas_n       (ddr3_cas_n_bc3      ),
         .ddr3_we_n        (ddr3_we_n_bc3       ),
         .ddr3_dm_tdqs_in  (ddr3_dm_tdqs_in_bc3 ),
         .ddr3_dm_tdqs_out (ddr3_dm_tdqs_out_bc3),
         .ddr3_ba          (ddr3_ba_bc3         ),
         .ddr3_addr        (ddr3_addr_bc3       ),
         .ddr3_data_in     (ddr3_data_in_bc3    ),
         .ddr3_data_out    (ddr3_data_out_bc3   ),
         .ddr3_data_all_in (ddr3_data_all_in_bc3),
         .ddr3_data_all_out(ddr3_data_all_out_bc3),
         .ddr3_dqs_in      (ddr3_dqs_in_bc3     ),
         .ddr3_dqs_out     (ddr3_dqs_out_bc3    ),
         .ddr3_dqs_n_in    (ddr3_dqs_n_in_bc3   ),
         .ddr3_dqs_n_out   (ddr3_dqs_n_out_bc3  ),
         .ddr3_tdqs_n      (ddr3_tdqs_n_bc3     ),
         .ddr3_odt         (ddr3_odt_bc3        ),
         .ddr3_rw          (ddr3_rw_bc3         ),
         .ddr3_ck          (clk                 ),

    //== I/O for ddr3 =====================
         .pad_rst_n        (pad_rst_n_bc3       ),
         .pad_cke          (pad_cke_bc3         ),
         .pad_cs_n         (pad_cs_n_bc3        ),
         .pad_ras_n        (pad_ras_n_bc3       ),
         .pad_cas_n        (pad_cas_n_bc3       ),
         .pad_we_n         (pad_we_n_bc3        ),
         .pad_dm_tdqs      (pad_dm_tdqs_bc3     ),
         .pad_ba           (pad_ba_bc3          ),
         .pad_addr         (pad_addr_bc3        ),
         .pad_dq           (pad_dq_bc3          ),
         .pad_dqs          (pad_dqs_bc3         ),
         .pad_dqs_n        (pad_dqs_n_bc3       ),
         .pad_tdqs_n       (pad_tdqs_n_bc3      ),
         .pad_odt          (pad_odt_bc3         ),
         .pad_ck           (pad_ck_bc3          ),
         .pad_ck_n         (pad_ck_n_bc3        ),
         .pad_dq_all       (pad_dq_all_bc3      )
);

// Instantiate 4 DDR3s
// Instantiate DDR3 0
ddr3 I_ddr3_0(
    .rst_n  (pad_rst_n_bc0  ),
    .ck     (pad_ck_bc0     ),
    .ck_n   (pad_ck_n_bc0   ),
    .cke    (pad_cke_bc0    ),
    .cs_n   (pad_cs_n_bc0   ),
    .ras_n  (pad_ras_n_bc0  ),
    .cas_n  (pad_cas_n_bc0  ),
    .we_n   (pad_we_n_bc0   ),
    .dm_tdqs(pad_dm_tdqs_bc0),
    .ba     (pad_ba_bc0     ),
    .addr   (pad_addr_bc0   ),
    .dq     (pad_dq_bc0     ),
    .dq_all (pad_dq_all_bc0 ),
    .dqs    (pad_dqs_bc0    ),
    .dqs_n  (pad_dqs_n_bc0  ),
    .tdqs_n (pad_tdqs_n_bc0 ),
    .odt    (pad_odt_bc0    )
);

// Instantiate DDR3 1
ddr3 I_ddr3_1(
    .rst_n  (pad_rst_n_bc1  ),
    .ck     (pad_ck_bc1     ),
    .ck_n   (pad_ck_n_bc1   ),
    .cke    (pad_cke_bc1    ),
    .cs_n   (pad_cs_n_bc1   ),
    .ras_n  (pad_ras_n_bc1  ),
    .cas_n  (pad_cas_n_bc1  ),
    .we_n   (pad_we_n_bc1   ),
    .dm_tdqs(pad_dm_tdqs_bc1),
    .ba     (pad_ba_bc1     ),
    .addr   (pad_addr_bc1   ),
    .dq     (pad_dq_bc1     ),
    .dq_all (pad_dq_all_bc1 ),
    .dqs    (pad_dqs_bc1    ),
    .dqs_n  (pad_dqs_n_bc1  ),
    .tdqs_n (pad_tdqs_n_bc1 ),
    .odt    (pad_odt_bc1    )
);

// Instantiate DDR3 2
ddr3 I_ddr3_2(
    .rst_n  (pad_rst_n_bc2  ),
    .ck     (pad_ck_bc2     ),
    .ck_n   (pad_ck_n_bc2   ),
    .cke    (pad_cke_bc2    ),
    .cs_n   (pad_cs_n_bc2   ),
    .ras_n  (pad_ras_n_bc2  ),
    .cas_n  (pad_cas_n_bc2  ),
    .we_n   (pad_we_n_bc2   ),
    .dm_tdqs(pad_dm_tdqs_bc2),
    .ba     (pad_ba_bc2     ),
    .addr   (pad_addr_bc2   ),
    .dq     (pad_dq_bc2     ),
    .dq_all (pad_dq_all_bc2 ),
    .dqs    (pad_dqs_bc2    ),
    .dqs_n  (pad_dqs_n_bc2  ),
    .tdqs_n (pad_tdqs_n_bc2 ),
    .odt    (pad_odt_bc2    )
);

// Instantiate DDR3 3
ddr3 I_ddr3_3(
    .rst_n  (pad_rst_n_bc3  ),
    .ck     (pad_ck_bc3     ),
    .ck_n   (pad_ck_n_bc3   ),
    .cke    (pad_cke_bc3    ),
    .cs_n   (pad_cs_n_bc3   ),
    .ras_n  (pad_ras_n_bc3  ),
    .cas_n  (pad_cas_n_bc3  ),
    .we_n   (pad_we_n_bc3   ),
    .dm_tdqs(pad_dm_tdqs_bc3),
    .ba     (pad_ba_bc3     ),
    .addr   (pad_addr_bc3   ),
    .dq     (pad_dq_bc3     ),
    .dq_all (pad_dq_all_bc3 ),
    .dqs    (pad_dqs_bc3    ),
    .dqs_n  (pad_dqs_n_bc3  ),
    .tdqs_n (pad_tdqs_n_bc3 ),
    .odt    (pad_odt_bc3    )
);
         
// connect it with the pattern
PATTERN I_PATTERN (
    .i_clk(clk),
    .i_clk2(clk2),
    .i_rst_n(rst_n),

    .i_command_valid(core_command_valid),
    .i_command(core_command),
    .i_write_data(core_write_data),
    .o_controller_ready(controller_ready),

    .o_read_data_valid(read_data_valid),
    .o_read_data(read_data)
);


endmodule
