// `include "define.sv"
// `include "userType_pkg.sv"
// import frontend_command_definition_pkg::*;
`define FRONTEND_WORD_SIZE  256
`define BACKEND_WORD_SIZE   FRONTEND_WORD_SIZE*4

`ifdef RTL
    `define CYCLE_TIME 3
`endif
`ifdef GATE
    `define CYCLE_TIME 3
`endif


`define TOTAL_CMD 500

`define TOTAL_SIM_CYCLE 50000

`define PATTERN_NUM 500

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

output logic i_clk;
output logic i_rst_n;

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
real CYCLE = `CYCLE_TIME;
integer write_command_count;
integer read_command_count;
integer issued_write_command_count;
integer issued_read_command_count;
integer RAW_count;

// integer total_latency;
// integer latency;

integer i, j;
integer i_pat;

// clock setting
always #(`CLK_DEFINE/2.0) i_clk = ~i_clk ;

// initial block
initial
begin
    reset_task;

    write_command_count = 0;
    read_command_count = 0;
    issued_write_command_count = 0;
    issued_read_command_count = 0;
    RAW_count = 0;

    for(i_pat = 0; i_pat < `PATTERN_NUM; i_pat = i_pat + 1)
    begin
        input_task;
    end

    congratulation;
end

// tasks
task reset_task;
    i_rst_n = 1'b1;
    force i_clk = 0;
    #CYCLE; i_rst_n = 1'b0;
    #CYCLE; i_rst_n = 1'b1;
    #(100);
    release i_clk;
endtask

always_ff @( posedge i_clk or negedge i_rst_n ) 
begin : I_INTERCONNECTION_REQUEST_VALID
    if(!i_rst_n) begin
        i_interconnection_request_valid <= 1'b0;
    end else begin
        if (o_scheduler_ready) begin
            i_interconnection_request_valid <= 1'b1;
        end else begin
            i_interconnection_request_valid <= 1'b0;
        end
    end
end

task input_task;
    // @(negedge clk);
endtask


task congratulation;
    $display("Congratulations! All tests passed");
    $finish;
endtask


endmodule
