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
                          // interconnection to frontend scheduler
                          o_controller_ready,
                          i_interconnection_request_valid,
                          i_interconnection_request,
                          i_interconnection_write_data,
                          i_interconnection_write_data_last,
                          // frontend scheduler to backend controller
                          i_backend_controller_ready,
                          o_frontend_command_valid,
                          o_frontend_command,
                          o_frontend_write_data,
                          o_frontend_write_data_last,
                          // backend controller to frontend scheduler
                          o_frontend_receive_ready,
                          i_returned_data_valid,
                          i_returned_data,
                          i_returned_data_last????????,
                          // frontend scheduler to interconnection
                          i_interconnection_ready,
                          o_controller_request_valid,
                          o_controller_read_data,
                          o_controller_read_data_last???????,
                          o_controller_request_ID,
                          o_controller_core_id, 
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

always_ff @(posedge clk or negedge rst_n) 
begin: INPUT_COMMAND
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
    if(command.op_type == OP_READ /*write command fifo same address*/) begin
        read_after_write = 1;
    end
    else begin
        read_after_write = 0;
    end
end

endmodule

