`timescale 1ns / 10ps
`include "userType_pkg.sv"
`include "PATTERN.sv"

`ifdef RTL
    `include "Globla_Controller.sv"
`endif
`ifdef GATE
    `include "Globla_Controller_SYN.sv"
`endif

module TESTBED;

logic clk;
logic rst_n;





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
Globla_Controller I_Globla_Controller (
    .i_clk(clk),
    .i_rst_n(rst_n),

    // .o_scheduler_ready(scheduler_ready),
    // .i_interconnection_request_valid(interconnection_request_valid),
    // .i_interconnection_request(interconnection_request),
    // .i_interconnection_write_data(interconnection_write_data),
    // .i_interconnection_write_data_last(interconnection_write_data_last),

    // .i_backend_controller_ready(backend_controller_ready),
    // .o_frontend_command_valid(frontend_command_valid),
    // .o_frontend_command(frontend_command),
    // .o_frontend_write_data(frontend_write_data),
    // .o_stall_backend_controller(o_stall_backend_controller),

    // .o_frontend_receive_ready(frontend_receive_ready),
    // .i_returned_data_valid(returned_data_valid),
    // .i_returned_data(returned_data),

    // .i_interconnection_ready(interconnection_ready),
    // .o_scheduler_request_valid(scheduler_request_valid),
    // .o_scheduler_read_data(scheduler_read_data),
    // .o_scheduler_read_data_last(scheduler_read_data_last),
    // .o_scheduler_request_id(scheduler_request_id),
    // .o_scheduler_core_num(scheduler_core_num)
);

// connect it with the pattern
PATTERN I_PATTERN (
    .i_clk(clk),
    .i_rst_n(rst_n),

    // .o_scheduler_ready(scheduler_ready),
    // .i_interconnection_request_valid(interconnection_request_valid),
    // .i_interconnection_request(interconnection_request),
    // .i_interconnection_write_data(interconnection_write_data),
    // .i_interconnection_write_data_last(interconnection_write_data_last),

    // .i_backend_controller_ready(backend_controller_ready),
    // .o_frontend_command_valid(frontend_command_valid),
    // .o_frontend_command(frontend_command),
    // .o_frontend_write_data(frontend_write_data),
    // .o_stall_backend_controller(o_stall_backend_controller),

    // .o_frontend_receive_ready(frontend_receive_ready),
    // .i_returned_data_valid(returned_data_valid),
    // .i_returned_data(returned_data),

    // .i_interconnection_ready(interconnection_ready),
    // .o_scheduler_request_valid(scheduler_request_valid),
    // .o_scheduler_read_data(scheduler_read_data),
    // .o_scheduler_read_data_last(scheduler_read_data_last),
    // .o_scheduler_request_id(scheduler_request_id),
    // .o_scheduler_core_num(scheduler_core_num)
);

endmodule
