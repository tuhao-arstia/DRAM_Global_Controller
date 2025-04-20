`ifdef RTL
    `define CYCLE_TIME 1
`endif
`ifdef GATE
    `define CYCLE_TIME 1
`endif

`define TOTAL_CMD 500


`define PATTERN_NUM 10

module PATTERN(
            i_clk,
            i_rst_n,
            
            // request channel
            i_command_valid,
            i_command,
            i_write_data,
            o_controller_ready,

            // read data channel
            o_read_data_valid,
            o_read_data,

            // command channel
            i_backend_controller_ready_bc0,
            o_frontend_command_valid_bc0,
            o_frontend_command_bc0,
            o_frontend_write_data_bc0,

            i_backend_controller_ready_bc1,
            o_frontend_command_valid_bc1,
            o_frontend_command_bc1,
            o_frontend_write_data_bc1,

            i_backend_controller_ready_bc2,
            o_frontend_command_valid_bc2,
            o_frontend_command_bc2,
            o_frontend_write_data_bc2,

            i_backend_controller_ready_bc3,
            o_frontend_command_valid_bc3,
            o_frontend_command_bc3,
            o_frontend_write_data_bc3,
            // returned data channel
            o_backend_controller_ren_bc0,
            i_returned_data_valid_bc0,
            i_returned_data_bc0,

            o_backend_controller_ren_bc1,
            i_returned_data_valid_bc1,
            i_returned_data_bc1,

            o_backend_controller_ren_bc2,
            i_returned_data_valid_bc2,
            i_returned_data_bc2,

            o_backend_controller_ren_bc3,
            i_returned_data_valid_bc3,
            i_returned_data_bc3
);

output logic i_clk;
output logic i_rst_n;

// request channel
output logic i_command_valid;
output frontend_command_t i_command;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_write_data;
input logic o_controller_ready;

// read data channel
input logic o_read_data_valid;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_read_data;

// command channel
output logic i_backend_controller_ready_bc0;
input logic o_frontend_command_valid_bc0;
input backend_command_t o_frontend_command_bc0;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_frontend_write_data_bc0;

output logic i_backend_controller_ready_bc1;
input logic o_frontend_command_valid_bc1;
input backend_command_t o_frontend_command_bc1;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_frontend_write_data_bc1;

output logic i_backend_controller_ready_bc2;
input logic o_frontend_command_valid_bc2;
input backend_command_t o_frontend_command_bc2;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_frontend_write_data_bc2;

output logic i_backend_controller_ready_bc3;
input logic o_frontend_command_valid_bc3;
input backend_command_t o_frontend_command_bc3;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_frontend_write_data_bc3;

 // returned data channel
input logic o_backend_controller_ren_bc0;
output logic i_returned_data_valid_bc0;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_returned_data_bc0;

input logic o_backend_controller_ren_bc1;
output logic i_returned_data_valid_bc1;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_returned_data_bc1;

input logic o_backend_controller_ren_bc2;
output logic i_returned_data_valid_bc2;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_returned_data_bc2;

input logic o_backend_controller_ren_bc3;
output logic i_returned_data_valid_bc3;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_returned_data_bc3;






// integer declaration
real CYCLE = `CYCLE_TIME;
// integer write_command_count;
// integer read_command_count;
// integer issued_write_command_count;
// integer issued_read_command_count;
// integer RAW_count;

// integer total_latency;
// integer latency;

integer i, j;
integer i_pat;

// clock setting
always #(`CYCLE_TIME/2.0) i_clk = ~i_clk ;

// initial block
initial
begin
    reset_task;

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


task input_task;
    // @(negedge clk);
    $display("HOIH");
endtask


task congratulation;
    $display("Congratulations! All tests passed");
    $finish;
endtask


endmodule
