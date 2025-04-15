`timescale 1ns / 10ps
`include "userType_pkg.sv"
// `include "PATTERN.sv"
`include "define.sv"

`define FRONTEND_WORD_SIZE  256
`define BACKEND_WORD_SIZE   FRONTEND_WORD_SIZE*4

`ifdef RTL
    `include "frontend_scheduler.sv"
`endif
// `ifdef GATE
    // `include "frontend_scheduler_SYN.v"
// `endif

module TESTBED;

import frontend_command_definition_pkg::*;

logic clk;
logic rst_n;

logic scheduler_ready;
logic interconnection_request_valid;
frontend_command_t interconnection_request;
logic [`FRONTEND_WORD_SIZE-1:0] interconnection_write_data;
logic interconnection_write_data_last;

logic backend_controller_ready;
logic frontend_command_valid;
frontend_command_t frontend_command;
logic [`BACKEND_WORD_SIZE-1:0] frontend_write_data;
logic frontend_write_data_last;

logic frontend_receive_ready;
logic returned_data_valid;
logic [`BACKEND_WORD_SIZE-1:0] returned_data;

logic interconnection_ready;
logic scheduler_request_valid;
logic [`FRONTEND_WORD_SIZE-1:0] scheduler_read_data;
logic scheduler_read_data_last;
req_id_t scheduler_request_id;
core_num_t scheduler_core_num;

initial begin
    `ifdef RTL
        $fsdbDumpfile("frontend_scheduler.fsdb");
        $fsdbDumpvars(0,"+all");
        $fsdbDumpSVA;
    `endif
    `ifdef GATE
        $fsdbDumpfile("frontend_scheduler_SYN.fsdb");
        $fsdbDumpvars(0,"+all");
        $fsdbDumpSVA;
    `endif
end

// Instantiate the init_ddr_phy_dram module
frontend_scheduler I_frontend_scheduler (
    .i_clk(clk),
    .i_rst_n(rst_n),

    .o_scheduler_ready(scheduler_ready),
    .i_interconnection_request_valid(interconnection_request_valid),
    .i_interconnection_request(interconnection_request),
    .i_interconnection_write_data(interconnection_write_data),
    .i_interconnection_write_data_last(interconnection_write_data_last),

    .i_backend_controller_ready(backend_controller_ready),
    .o_frontend_command_valid(frontend_command_valid),
    .o_frontend_command(frontend_command),
    .o_frontend_write_data(frontend_write_data),
    .o_stall_backend_controller(o_stall_backend_controller),

    .o_frontend_receive_ready(frontend_receive_ready),
    .i_returned_data_valid(returned_data_valid),
    .i_returned_data(returned_data),

    .i_interconnection_ready(interconnection_ready),
    .o_scheduler_request_valid(scheduler_request_valid),
    .o_scheduler_read_data(scheduler_read_data),
    .o_scheduler_read_data_last(scheduler_read_data_last),
    .o_scheduler_request_id(scheduler_request_id),
    .o_scheduler_core_num(scheduler_core_num)
);

// connect it with the pattern
PATTERN I_PATTERN (
    .i_clk(clk),
    .i_rst_n(rst_n),

    .o_scheduler_ready(scheduler_ready),
    .i_interconnection_request_valid(interconnection_request_valid),
    .i_interconnection_request(interconnection_request),
    .i_interconnection_write_data(interconnection_write_data),
    .i_interconnection_write_data_last(interconnection_write_data_last),

    .i_backend_controller_ready(backend_controller_ready),
    .o_frontend_command_valid(frontend_command_valid),
    .o_frontend_command(frontend_command),
    .o_frontend_write_data(frontend_write_data),
    .o_stall_backend_controller(o_stall_backend_controller),

    .o_frontend_receive_ready(frontend_receive_ready),
    .i_returned_data_valid(returned_data_valid),
    .i_returned_data(returned_data),

    .i_interconnection_ready(interconnection_ready),
    .o_scheduler_request_valid(scheduler_request_valid),
    .o_scheduler_read_data(scheduler_read_data),
    .o_scheduler_read_data_last(scheduler_read_data_last),
    .o_scheduler_request_id(scheduler_request_id),
    .o_scheduler_core_num(scheduler_core_num)
);

endmodule
