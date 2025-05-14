////////////////////////////////////////////////////////////////////////
// Project Name: 3D-DRAM Memory Controller
// Task Name   : Memory Controller
// Module Name : Shift Register Queues
// File Name   : SRQ.sv
// Description : Queue made of shift registers, to store temporary datas, the time for the value to propogates to the 
//               TAIL register takes time DEPTH-1 cycles, fall through functionality can be added to boost the performance of latency if needed
// Author      : YEH SHUN-LIANG
// Revision History:
// Date        : 2025/04/01
////////////////////////////////////////////////////////////////////////
module SRQ #(
    parameter WIDTH = 1024,
    parameter DEPTH = 4
)(
    input wire clk,
    input wire rst,
    input push,
    output reg out_valid,
    input wire [WIDTH-1:0] data_in,
    input wire pop,
    output reg [WIDTH-1:0] data_out,
    output reg full,
    output reg empty,
    output wire error_flag
);

    logic valid_shift_register_line[DEPTH-1:0];
    logic [WIDTH-1:0] data_shift_register_line[DEPTH-1:0];

    logic valid_shift_register_line_next[DEPTH-1:0];
    logic [WIDTH-1:0] data_shift_register_line_next[DEPTH-1:0];

    // flags
    assign full = valid_shift_register_line[0] ==1'b1 && valid_shift_register_line[1] == 1'b1 && valid_shift_register_line[2] == 1'b1 && valid_shift_register_line[3] == 1'b1;
    assign empty = valid_shift_register_line[0] == 1'b0 && valid_shift_register_line[1] == 1'b0 && valid_shift_register_line[2] == 1'b0 && valid_shift_register_line[3] == 1'b0;
    assign out_valid = valid_shift_register_line[DEPTH-1];
    assign data_out = data_shift_register_line[DEPTH-1];
    assign error_flag = (push && full) || (pop && empty && valid_shift_register_line[DEPTH-1] == 1'b0);

    always_ff @(posedge clk) begin:DATA_SHIFT_REGISTER_CHAIN
        for (int i = 0; i < DEPTH; i++) begin // Datapath does not need reset
            data_shift_register_line[i] <= data_shift_register_line_next[i];
        end
    end

    always_ff@(posedge clk or negedge rst) begin : VALID_LOGIC_SHIFT_REGISTER_CHAIN
        if (!rst) begin // control path requires for correct flow control
            for (int i = 0; i < DEPTH; i++) begin
                valid_shift_register_line[i] <= 1'b0;
            end
        end else begin
            for (int i = 0; i < DEPTH; i++) begin
                valid_shift_register_line[i] <= valid_shift_register_line_next[i];
            end
        end
    end

    // HEAD    1 2    3
    // Tail   Middle  Tail 
    always_comb begin : NEXT_LOGIC
        //initialization
        for (int i = 0; i < DEPTH; i++) begin
            valid_shift_register_line_next[i] = valid_shift_register_line[i];
            data_shift_register_line_next[i] = data_shift_register_line[i];
        end
        // head, mark as arr[0]
        // Can only accept value if push is high and not full,
        // If the next register's valid is 0, and the current register's valid is 1, then we can push the value to the next register
        // If the next register's valid is 1, and the current register's valid is 0, then we can push the value to the current register
        if((pop && !empty) || (push && !full) || (valid_shift_register_line[1] == 1'b0) ) begin
            valid_shift_register_line_next[0] = push;
            data_shift_register_line_next[0] = data_in; // always accept the data in, but only push it if the conditions are met
        end 
        else begin // remains
            valid_shift_register_line_next[0] = valid_shift_register_line[0];
            data_shift_register_line_next[0] = data_shift_register_line[0];
        end

        // middle shift register lines
        for(int i = 1; i < DEPTH-1; i++) begin
            // Can receive value if valid is low,
            // Can only receive value from the previous stage if pop is high and not empty,
            // If the next register's valid is 0, and the current register's valid is 1, then we can push the value to the next register
            // If the next register's valid is 1, and the current register's valid is 0, then we can push the value to the current register
            if (valid_shift_register_line[i] == 1'b1 && valid_shift_register_line[i+1] == 1'b1 && !pop) begin //Current register is not empty
                // remains
                valid_shift_register_line_next[i] = valid_shift_register_line[i];
                data_shift_register_line_next[i] = data_shift_register_line[i];
            end else begin
                // Current register is empty, so we can push the value from the previous stage in
                valid_shift_register_line_next[i] = valid_shift_register_line[i-1];
                data_shift_register_line_next[i] = data_shift_register_line[i-1];
            end
        end

        // tail as last register, mark as arr[3], add fall-through functionality here if needed
        if((pop && !empty) || valid_shift_register_line[DEPTH-1] == 1'b0) begin
            // Unconditionally shifting Receive value from previous stage
            valid_shift_register_line_next[DEPTH-1] = valid_shift_register_line[DEPTH-2];
            data_shift_register_line_next[DEPTH-1]  = data_shift_register_line[DEPTH-2];
        end
        else begin
            valid_shift_register_line_next[DEPTH-1] = valid_shift_register_line[DEPTH-1];
            data_shift_register_line_next[DEPTH-1] = data_shift_register_line[DEPTH-1];
        end 
    end
endmodule






































