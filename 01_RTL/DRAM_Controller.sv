////////////////////////////////////////////////////////////////////////
// Project Name: 
// Task Name   : DRAM Controller
// Module Name : DRAM_Controller
// File Name   : DRAM_Controller.sv
////////////////////////////////////////////////////////////////////////

`include "Global_Controller.sv"
`include "Backend_Controller.sv"

module DRAM_Controller(
                        // System Clock
                        power_on_rst_n,
                        clk,
                        clk2,

                        //=== Interface with Core ===
                        // request channel
                        command_valid,
                        command,
                        write_data,
                        controller_ready,

                        // read data channel
                        read_data_valid,
                        read_data,

                        //=== I/O from DDR3 interface ===
                        // DDR3_0
                        rst_n_0,
                        cke_0,
                        cs_n_0,
                        ras_n_0,
                        cas_n_0,
                        we_n_0,
                        dm_tdqs_in_0,
                        dm_tdqs_out_0,
                        ba_0,
                        addr_0,
                        data_in_0,
                        data_out_0,
                        data_all_in_0,
                        data_all_out_0,
                        dqs_in_0,
                        dqs_out_0,
                        dqs_n_in_0,
                        dqs_n_out_0,
                        tdqs_n_0,
                        odt_0,
                        ddr3_rw_0,

                        // DDR3_1
                        rst_n_1,
                        cke_1,
                        cs_n_1,
                        ras_n_1,
                        cas_n_1,
                        we_n_1,
                        dm_tdqs_in_1,
                        dm_tdqs_out_1,
                        ba_1,
                        addr_1,
                        data_in_1,
                        data_out_1,
                        data_all_in_1,
                        data_all_out_1,
                        dqs_in_1,
                        dqs_out_1,
                        dqs_n_in_1,
                        dqs_n_out_1,
                        tdqs_n_1,
                        odt_1,
                        ddr3_rw_1,

                        // DDR3_2
                        rst_n_2,
                        cke_2,
                        cs_n_2,
                        ras_n_2,
                        cas_n_2,
                        we_n_2,
                        dm_tdqs_in_2,
                        dm_tdqs_out_2,
                        ba_2,
                        addr_2,
                        data_in_2,
                        data_out_2,
                        data_all_in_2,
                        data_all_out_2,
                        dqs_in_2,
                        dqs_out_2,
                        dqs_n_in_2,
                        dqs_n_out_2,
                        tdqs_n_2,
                        odt_2,
                        ddr3_rw_2,

                        // DDR3_3
                        rst_n_3,
                        cke_3,
                        cs_n_3,
                        ras_n_3,
                        cas_n_3,
                        we_n_3,
                        dm_tdqs_in_3,
                        dm_tdqs_out_3,
                        ba_3,
                        addr_3,
                        data_in_3,
                        data_out_3,
                        data_all_in_3,
                        data_all_out_3,
                        dqs_in_3,
                        dqs_out_3,
                        dqs_n_in_3,
                        dqs_n_out_3,
                        tdqs_n_3,
                        odt_3,
                        ddr3_rw_3
);

// System Clock
input logic power_on_rst_n;
input logic clk;
input logic clk2;

//=== Interface with Core ===
// request channel
input logic command_valid;
input frontend_command_t command;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] write_data;
output logic controller_ready;

// read data channel
output logic read_data_valid;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] read_data;

//== I/O from DDR3 interface ===
// DDR3_0 signals
output wire   rst_n_0;
output wire   cke_0;
output wire   cs_n_0;
output wire   ras_n_0;
output wire   cas_n_0;
output wire   we_n_0;
input [`DM_BITS-1:0]  dm_tdqs_in_0;
output[`DM_BITS-1:0]  dm_tdqs_out_0;
output[`BA_BITS-1:0]  ba_0;
output[`ADDR_BITS-1:0] addr_0;
input [`DQ_BITS-1:0] data_in_0;
output [`DQ_BITS-1:0] data_out_0;
input [`DQ_BITS*8-1:0] data_all_in_0;
output [`DQ_BITS*8-1:0] data_all_out_0;
input [`DQS_BITS-1:0] dqs_in_0;
output[`DQS_BITS-1:0] dqs_out_0;
input [`DQS_BITS-1:0] dqs_n_in_0;
output[`DQS_BITS-1:0] dqs_n_out_0;
input [`DQS_BITS-1:0] tdqs_n_0;
output wire odt_0;
output wire ddr3_rw_0;

// DDR3_1 signals
output wire   rst_n_1;
output wire   cke_1;
output wire   cs_n_1;
output wire   ras_n_1;
output wire   cas_n_1;
output wire   we_n_1;
input [`DM_BITS-1:0]  dm_tdqs_in_1;
output[`DM_BITS-1:0]  dm_tdqs_out_1;
output[`BA_BITS-1:0]  ba_1;
output[`ADDR_BITS-1:0] addr_1;
input [`DQ_BITS-1:0] data_in_1;
output [`DQ_BITS-1:0] data_out_1;
input [`DQ_BITS*8-1:0] data_all_in_1;
output [`DQ_BITS*8-1:0] data_all_out_1;
input [`DQS_BITS-1:0] dqs_in_1;
output[`DQS_BITS-1:0] dqs_out_1;
input [`DQS_BITS-1:0] dqs_n_in_1;
output[`DQS_BITS-1:0] dqs_n_out_1;
input [`DQS_BITS-1:0] tdqs_n_1;
output wire odt_1;
output wire ddr3_rw_1;

// DDR3_2 signals
output wire   rst_n_2;
output wire   cke_2;
output wire   cs_n_2;
output wire   ras_n_2;
output wire   cas_n_2;
output wire   we_n_2;
input [`DM_BITS-1:0]  dm_tdqs_in_2;
output[`DM_BITS-1:0]  dm_tdqs_out_2;
output[`BA_BITS-1:0]  ba_2;
output[`ADDR_BITS-1:0] addr_2;
input [`DQ_BITS-1:0] data_in_2;
output [`DQ_BITS-1:0] data_out_2;
input [`DQ_BITS*8-1:0] data_all_in_2;
output [`DQ_BITS*8-1:0] data_all_out_2;
input [`DQS_BITS-1:0] dqs_in_2;
output[`DQS_BITS-1:0] dqs_out_2;
input [`DQS_BITS-1:0] dqs_n_in_2;
output[`DQS_BITS-1:0] dqs_n_out_2;
input [`DQS_BITS-1:0] tdqs_n_2;
output wire odt_2;
output wire ddr3_rw_2;

// DDR3_3 signals
output wire   rst_n_3;
output wire   cke_3;
output wire   cs_n_3;
output wire   ras_n_3;
output wire   cas_n_3;
output wire   we_n_3;
input [`DM_BITS-1:0]  dm_tdqs_in_3;
output[`DM_BITS-1:0]  dm_tdqs_out_3;
output[`BA_BITS-1:0]  ba_3;
output[`ADDR_BITS-1:0] addr_3;
input [`DQ_BITS-1:0] data_in_3;
output [`DQ_BITS-1:0] data_out_3;
input [`DQ_BITS*8-1:0] data_all_in_3;
output [`DQ_BITS*8-1:0] data_all_out_3;
input [`DQS_BITS-1:0] dqs_in_3;
output[`DQS_BITS-1:0] dqs_out_3;
input [`DQS_BITS-1:0] dqs_n_in_3;
output[`DQS_BITS-1:0] dqs_n_out_3;
input [`DQS_BITS-1:0] tdqs_n_3;
output wire odt_3;
output wire ddr3_rw_3;

//----------------------------------------------------//
//                    Declaration                     //
//----------------------------------------------------//
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


//----------------------------------------------------//
//                1 Global Controller                 //
//----------------------------------------------------//
Global_Controller Global_Controller (
    .i_clk(clk),
    .i_rst_n(power_on_rst_n),

    .i_command_valid(command_valid),
    .i_command(command),
    .i_write_data(write_data),
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

//----------------------------------------------------//
//                4 Backend Controller                //
//----------------------------------------------------//

// Instantiate Backend Controller 0
Backend_Controller BackendController_0(
//== I/O from System ===============
         .power_on_rst_n(power_on_rst_n),
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
         .rst_n       (rst_n_0      ),
         .cke         (cke_0        ),
         .cs_n        (cs_n_0       ),
         .ras_n       (ras_n_0      ),
         .cas_n       (cas_n_0      ),
         .we_n        (we_n_0       ),
         .dm_tdqs_in  (dm_tdqs_in_0 ),
         .dm_tdqs_out (dm_tdqs_out_0),
         .ba          (ba_0         ),
         .addr        (addr_0       ),
         .data_in     (data_in_0    ),
         .data_out    (data_out_0   ),
         .data_all_in (data_all_in_0),
         .data_all_out(data_all_out_0),
         .dqs_in      (dqs_in_0     ),
         .dqs_out     (dqs_out_0    ),
         .dqs_n_in    (dqs_n_in_0   ),
         .dqs_n_out   (dqs_n_out_0  ),
         .tdqs_n      (tdqs_n_0     ),
         .odt         (odt_0        ),
         .ddr3_rw     (ddr3_rw_0    )
);

// Instantiate Backend Controller 1
Backend_Controller BackendController_1(
//== I/O from System ===============
         .power_on_rst_n(power_on_rst_n),
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
         .rst_n       (rst_n_1      ),
         .cke         (cke_1        ),
         .cs_n        (cs_n_1       ),
         .ras_n       (ras_n_1      ),
         .cas_n       (cas_n_1      ),
         .we_n        (we_n_1       ),
         .dm_tdqs_in  (dm_tdqs_in_1 ),
         .dm_tdqs_out (dm_tdqs_out_1),
         .ba          (ba_1         ),
         .addr        (addr_1       ),
         .data_in     (data_in_1    ),
         .data_out    (data_out_1   ),
         .data_all_in (data_all_in_1),
         .data_all_out(data_all_out_1),
         .dqs_in      (dqs_in_1     ),
         .dqs_out     (dqs_out_1    ),
         .dqs_n_in    (dqs_n_in_1   ),
         .dqs_n_out   (dqs_n_out_1  ),
         .tdqs_n      (tdqs_n_1     ),
         .odt         (odt_1        ),
         .ddr3_rw     (ddr3_rw_1    )
);

// Instantiate Backend Controller 2
Backend_Controller BackendController_2(
//== I/O from System ===============
         .power_on_rst_n(power_on_rst_n),
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
         .rst_n       (rst_n_2      ),
         .cke         (cke_2        ),
         .cs_n        (cs_n_2       ),
         .ras_n       (ras_n_2      ),
         .cas_n       (cas_n_2      ),
         .we_n        (we_n_2       ),
         .dm_tdqs_in  (dm_tdqs_in_2 ),
         .dm_tdqs_out (dm_tdqs_out_2),
         .ba          (ba_2         ),
         .addr        (addr_2       ),
         .data_in     (data_in_2    ),
         .data_out    (data_out_2   ),
         .data_all_in (data_all_in_2),
         .data_all_out(data_all_out_2),
         .dqs_in      (dqs_in_2     ),
         .dqs_out     (dqs_out_2    ),
         .dqs_n_in    (dqs_n_in_2   ),
         .dqs_n_out   (dqs_n_out_2  ),
         .tdqs_n      (tdqs_n_2     ),
         .odt         (odt_2        ),
         .ddr3_rw     (ddr3_rw_2    )
);

// Instantiate Backend Controller 3
Backend_Controller BackendController_3(
//== I/O from System ===============
         .power_on_rst_n(power_on_rst_n),
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
         .rst_n       (rst_n_3      ),
         .cke         (cke_3        ),
         .cs_n        (cs_n_3       ),
         .ras_n       (ras_n_3      ),
         .cas_n       (cas_n_3      ),
         .we_n        (we_n_3       ),
         .dm_tdqs_in  (dm_tdqs_in_3 ),
         .dm_tdqs_out (dm_tdqs_out_3),
         .ba          (ba_3         ),
         .addr        (addr_3       ),
         .data_in     (data_in_3    ),
         .data_out    (data_out_3   ),
         .data_all_in (data_all_in_3),
         .data_all_out(data_all_out_3),
         .dqs_in      (dqs_in_3     ),
         .dqs_out     (dqs_out_3    ),
         .dqs_n_in    (dqs_n_in_3   ),
         .dqs_n_out   (dqs_n_out_3  ),
         .tdqs_n      (tdqs_n_3     ),
         .odt         (odt_3        ),
         .ddr3_rw     (ddr3_rw_3    )
);

endmodule

