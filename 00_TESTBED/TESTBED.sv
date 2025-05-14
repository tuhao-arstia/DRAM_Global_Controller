`timescale 1ns / 10ps
`include "frontend_cmd_definition_pkg.sv"
`include "PATTERN.sv"

`ifdef RTL
    `include "DRAM_Controller.sv"
    `include "MEM_PAD.sv"
    `include "ddr3.sv"
`endif
`ifdef GATE
    `include "DRAM_Controller_SYN.v"
    `include "MEM_PAD.sv"
    `include "ddr3.sv"
`endif

module TESTBED;

`include "2048Mb_ddr3_parameters.vh"

initial begin
    `ifdef RTL
        $fsdbDumpfile("DRAM_Controller.fsdb");
        $fsdbDumpvars(0,"+all");
        $fsdbDumpSVA;
    `endif
    `ifdef GATE
        // $sdf_annotate("DRAM_Controller_SYN.sdf", u_DRAM_Controller);
        // $fsdbDumpfile("DRAM_Controller_SYN.fsdb");
        // $fsdbDumpvars(0,"+all");
        // $fsdbDumpSVA;
    `endif
end

logic power_on_rst_n;
logic clk;
logic clk2;

// Global Controller Signals(Core-GC)
logic core_command_valid;
frontend_command_t core_command;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] core_write_data;
logic global_controller_ready;

logic read_data_valid;
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] read_data;

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

// Instantiate the DRAM Controller module
DRAM_Controller u_DRAM_Controller (
    .power_on_rst_n(power_on_rst_n),
    .clk(clk),
    .clk2(clk2),

    //=== Interface with Core ===
    .command_valid(core_command_valid),
    .command(core_command),
    .write_data(core_write_data),
    .controller_ready(global_controller_ready),

    .read_data_valid(read_data_valid),
    .read_data(read_data),

    //=== I/O from DDR3 interface ===
    .rst_n_0(ddr3_rst_n_bc0),
    .cke_0(ddr3_cke_bc0),
    .cs_n_0(ddr3_cs_n_bc0),
    .ras_n_0(ddr3_ras_n_bc0),
    .cas_n_0(ddr3_cas_n_bc0),
    .we_n_0(ddr3_we_n_bc0),
    .dm_tdqs_in_0(ddr3_dm_tdqs_in_bc0),
    .dm_tdqs_out_0(ddr3_dm_tdqs_out_bc0),
    .ba_0(ddr3_ba_bc0),
    .addr_0(ddr3_addr_bc0),
    .data_in_0(ddr3_data_in_bc0),
    .data_out_0(ddr3_data_out_bc0),
    .data_all_in_0(ddr3_data_all_in_bc0),
    .data_all_out_0(ddr3_data_all_out_bc0),
    .dqs_in_0(ddr3_dqs_in_bc0),
    .dqs_out_0(ddr3_dqs_out_bc0),
    .dqs_n_in_0(ddr3_dqs_n_in_bc0),
    .dqs_n_out_0(ddr3_dqs_n_out_bc0),
    .tdqs_n_0(ddr3_tdqs_n_bc0),
    .odt_0(ddr3_odt_bc0),
    .ddr3_rw_0(ddr3_rw_bc0),

    .rst_n_1(ddr3_rst_n_bc1),
    .cke_1(ddr3_cke_bc1),
    .cs_n_1(ddr3_cs_n_bc1),
    .ras_n_1(ddr3_ras_n_bc1),
    .cas_n_1(ddr3_cas_n_bc1),
    .we_n_1(ddr3_we_n_bc1),
    .dm_tdqs_in_1(ddr3_dm_tdqs_in_bc1),
    .dm_tdqs_out_1(ddr3_dm_tdqs_out_bc1),
    .ba_1(ddr3_ba_bc1),
    .addr_1(ddr3_addr_bc1),
    .data_in_1(ddr3_data_in_bc1),
    .data_out_1(ddr3_data_out_bc1),
    .data_all_in_1(ddr3_data_all_in_bc1),
    .data_all_out_1(ddr3_data_all_out_bc1),
    .dqs_in_1(ddr3_dqs_in_bc1),
    .dqs_out_1(ddr3_dqs_out_bc1),
    .dqs_n_in_1(ddr3_dqs_n_in_bc1),
    .dqs_n_out_1(ddr3_dqs_n_out_bc1),
    .tdqs_n_1(ddr3_tdqs_n_bc1),
    .odt_1(ddr3_odt_bc1),
    .ddr3_rw_1(ddr3_rw_bc1),

    .rst_n_2(ddr3_rst_n_bc2),
    .cke_2(ddr3_cke_bc2),
    .cs_n_2(ddr3_cs_n_bc2),
    .ras_n_2(ddr3_ras_n_bc2),
    .cas_n_2(ddr3_cas_n_bc2),
    .we_n_2(ddr3_we_n_bc2),
    .dm_tdqs_in_2(ddr3_dm_tdqs_in_bc2),
    .dm_tdqs_out_2(ddr3_dm_tdqs_out_bc2),
    .ba_2(ddr3_ba_bc2),
    .addr_2(ddr3_addr_bc2),
    .data_in_2(ddr3_data_in_bc2),
    .data_out_2(ddr3_data_out_bc2),
    .data_all_in_2(ddr3_data_all_in_bc2),
    .data_all_out_2(ddr3_data_all_out_bc2),
    .dqs_in_2(ddr3_dqs_in_bc2),
    .dqs_out_2(ddr3_dqs_out_bc2),
    .dqs_n_in_2(ddr3_dqs_n_in_bc2),
    .dqs_n_out_2(ddr3_dqs_n_out_bc2),
    .tdqs_n_2(ddr3_tdqs_n_bc2),
    .odt_2(ddr3_odt_bc2),
    .ddr3_rw_2(ddr3_rw_bc2),

    .rst_n_3(ddr3_rst_n_bc3),
    .cke_3(ddr3_cke_bc3),
    .cs_n_3(ddr3_cs_n_bc3),
    .ras_n_3(ddr3_ras_n_bc3),
    .cas_n_3(ddr3_cas_n_bc3),
    .we_n_3(ddr3_we_n_bc3),
    .dm_tdqs_in_3(ddr3_dm_tdqs_in_bc3),
    .dm_tdqs_out_3(ddr3_dm_tdqs_out_bc3),
    .ba_3(ddr3_ba_bc3),
    .addr_3(ddr3_addr_bc3),
    .data_in_3(ddr3_data_in_bc3),
    .data_out_3(ddr3_data_out_bc3),
    .data_all_in_3(ddr3_data_all_in_bc3),
    .data_all_out_3(ddr3_data_all_out_bc3),
    .dqs_in_3(ddr3_dqs_in_bc3),
    .dqs_out_3(ddr3_dqs_out_bc3),
    .dqs_n_in_3(ddr3_dqs_n_in_bc3),
    .dqs_n_out_3(ddr3_dqs_n_out_bc3),
    .tdqs_n_3(ddr3_tdqs_n_bc3),
    .odt_3(ddr3_odt_bc3),
    .ddr3_rw_3(ddr3_rw_bc3)
);

// Instantiate 4 MEM_PADs
// Instantiate MEM_PAD 0
MEM_PAD u_MEM_PAD_0(
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
MEM_PAD u_MEM_PAD_1(
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
MEM_PAD u_MEM_PAD_2(
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
MEM_PAD u_MEM_PAD_3(
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
ddr3 u_ddr3_0(
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
ddr3 u_ddr3_1(
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
ddr3 u_ddr3_2(
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
ddr3 u_ddr3_3(
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
// be careful with the port name
PATTERN u_PATTERN (
    .i_clk(clk),
    .i_clk2(clk2),
    .i_rst_n(power_on_rst_n),

    .i_command_valid(core_command_valid),
    .i_command(core_command),
    .i_write_data(core_write_data),
    .o_controller_ready(global_controller_ready),

    .o_read_data_valid(read_data_valid),
    .o_read_data(read_data)
);


endmodule