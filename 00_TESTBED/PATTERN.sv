`ifdef RTL
    `define CYCLE_TIME 1
`endif
`ifdef GATE
    `define CYCLE_TIME 1
`endif

`define TOTAL_CMD 500//?

`define TOTAL_SIM_CYCLE 50000

`define PATTERN_NUM 500

module PATTERN(
    i_clk,
    i_rst_n,




);

output logic i_clk;
output logic i_rst_n;





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
always #(`CYCLE_TIME/2.0) i_clk = ~i_clk ;

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


task input_task;
    // @(negedge clk);
endtask


task congratulation;
    $display("Congratulations! All tests passed");
    $finish;
endtask


endmodule
