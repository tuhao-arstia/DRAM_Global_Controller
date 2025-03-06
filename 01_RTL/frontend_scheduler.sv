////////////////////////////////////////////////////////////////////////
// Project Name: 
// Task Name   : DRAM Frontend Scheduler
// Module Name : frontend_scheduler
// File Name   : frontend_scheduler.sv
// Description : schedule issued commands
////////////////////////////////////////////////////////////////////////

`include "userType_pkg.sv"
`include "define.sv"
`include "FIFO.sv"

import frontend_command_definition_pkg::*;

module frontend_scheduler(
                          clk,
                          rst_n,
                          something
);

import usertype::*;

input clk;
input rst_n;
frontend_command_t i_command;
input i_wlast;
input i_wdata;




// command decoder
frontend_command_t command;
// busy flag to not to accept new command when the scheduler is busy

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        command <= 0;
    end
    else begin
        // if handshake
        command <= i_command;
        // else keep the command
    end
end

// RAW detection
logic read_after_write;
always_comb begin
    if(command.op_type == OP_READ) begin
        read_after_write = 1;
    end
    else begin
        read_after_write = 0;
    end
end

endmodule

