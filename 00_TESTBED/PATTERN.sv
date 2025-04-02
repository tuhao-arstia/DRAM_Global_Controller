`include "define.sv"
`include "userType_pkg.sv"

module PATTERN(
    i_clk,
    i_rst_n,

    o_scheduler_ready,
    i_interconnection_request_valid,
    i_interconnection_request,
    i_interconnection_write_data,
    i_interconnection_write_data_last,

    i_backend_controller_ready,
    o_frontend_command_valid,
    o_frontend_command,
    o_frontend_write_data,
    o_stall_backend_controller,

    o_frontend_receive_ready,
    i_returned_data_valid,
    i_returned_data,

    i_interconnection_ready,
    o_scheduler_request_valid,
    o_scheduler_read_data,
    o_scheduler_read_data_last,
    o_scheduler_request_id,
    o_scheduler_core_num
);

import frontend_command_definition_pkg::*;

output logic clk1;
output logic rst_n;

input logic o_scheduler_ready;
output logic i_interconnection_request_valid;
output frontend_command_t i_interconnection_request;
output logic [`FRONTEND_WORD_SIZE-1:0] i_interconnection_write_data;
output logic i_interconnection_write_data_last;

output logic i_backend_controller_ready;
input logic o_frontend_command_valid;
input frontend_command_t o_frontend_command;
input logic [`BACKEND_WORD_SIZE-1:0] o_frontend_write_data;
input logic o_stall_backend_controller;

input logic o_frontend_receive_ready;
output logic i_returned_data_valid;
output logic [`BACKEND_WORD_SIZE-1:0] i_returned_data;

output logic i_interconnection_ready;
input logic o_scheduler_request_valid;  
input logic [`FRONTEND_WORD_SIZE-1:0] o_scheduler_read_data;
input logic o_scheduler_read_data_last;
input req_id_t o_scheduler_request_id;
input core_num_t o_scheduler_core_num;

// integer declaration

initial exe_task;

// initial force_exiting_task;
//======================================
//              MAIN
//======================================
task exe_task;
    reset_task();
    wait_initialization();
    send_command();
    congratulation();
endtask

//======================================
//              TASKS
//======================================
task clock_cycle_cnt_task;
    forever begin
        clock_cycle = clock_cycle + 1;
        @(negedge clk1);
    end
endtask


task force_exiting_task;
    forever begin
        // if(clock_cycle > SIM_CLK_CYCLE)
            // $finish;
        @(negedge clk1);
    end
endtask

task reset_task;
    // reseting the ddr3
    // display
    $display("======================================");
    $display("====       Resetting the DDR3      ===");
    $display("======================================");
    rst_n = 0;
    clk1 = 0;
    clk2 = 0;

    #(`CLK_DEFINE*10) rst_n = 0;
    #(`CLK_DEFINE*10) rst_n = 1;
    $display("======================================");
    $display("====       Done Reset the DDR3     ===");
    $display("======================================");

endtask

task wait_initialization;
    // waiting for the initialization to be done
    $display("======================================");
    $display("====     WAITING INITIALIZATION    ===");
    $display("======================================");
    forever begin
        if(init_done_flag == 1'b1) // MEANING the initialization is done
            break;
        @(negedge clk1);
    end
    $display("=======================================");
    $display("====     DONE INITILIZATION         ===");
    $display("=======================================");
endtask

task gen_clk;
    forever begin
        #(`CLK_DEFINE/2.0) clk1 = ~clk1;
    end
endtask

task gen_clk2;
    forever begin
        #(`CLK_DEFINE/4.0) clk2 = ~clk2;
    end
endtask

task send_command;
    // sending the command
    $display("======================================");
    $display("====     SENDING COMMANDS          ===");
    $display("======================================");
    // sending the command
    @(negedge clk1);
endtask

task congratulation;
    $display("Congratulations! All tests passed");
    $finish;
endtask


endmodule
