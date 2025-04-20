`timescale 1ns / 10ps
`include "frontend_cmd_definition_pkg.sv"
`include "PATTERN.sv"

`ifdef RTL
    `include "Global_Controller.sv"
`endif
`ifdef GATE
    `include "Global_Controller_SYN.sv"
`endif

module TESTBED;

logic clk;
logic rst_n;

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


initial begin
    `ifdef RTL
        $fsdbDumpfile("Global_Controller.fsdb");
        $fsdbDumpvars(0,"+all");
        $fsdbDumpSVA;
    `endif
    `ifdef GATE
        $fsdbDumpfile("Global_Controller_SYN.fsdb");
        $fsdbDumpvars(0,"+all");
        $fsdbDumpSVA;
    `endif
end

// Instantiate the init_ddr_phy_dram module
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

// connect it with the pattern
PATTERN I_PATTERN (
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


endmodule
