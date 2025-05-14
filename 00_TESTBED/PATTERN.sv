////////////////////////////////////////////////////////////////////////
// Project Name:
// Task Name   : DRAM Controller PATTERN
// File Name   : PATTERN.sv
//
// Description :
// 1. This is the test pattern for DRAM controller
//    (1 Global Controller and 4 Backend Controllers)
//
// 2. This file provides the different test patterns as listed below
//    a) ROW_MAJOR_PATTERN
//        Read Order:
//        1) Bank order: 0, 1, 2, 3, repeat...
//        2) Row and Column order: row-major order.
//
//    b) ROW_MAJOR_BANK_BURST_PATTERN
//        Read Order:
//        1) Bank order: 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, repeat...
//        2) Row and Column order: row-major order.
//
//    c) COL_MAJOR_PATTERN
//        Read Order:
//        1) Bank order: 0, 1, 2, 3, repeat...
//        2) Row and Column order: column-major order.
//
//    d) COL_MAJOR_BANK_BURST_PATTERN
//        Read Order:
//        1) Bank order: 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, repeat...
//        2) Row and Column order: column-major order.
//
//    e) REVERSE_ROW_MAJOR_PATTERN
//        To test the right bottom corner of the DRAM.
//        Read Order:
//        1) Bank order: 0, 1, 2, 3, repeat...
//        2) Row and Column order: row-major order in reverse direction.
//
//    f) ALL_SAME_ADDR_PATTERN
//        Repeatedly read row 0, col 0, bank 0 for multiple times.
//        And check whether the DRAM refresh operation is performed correctly during the test.
//
//    g) RAW_INTERLEAVE_PATTERN
//        Write and then read the same address (RAW Hazard check) in raster order.
//
// 3. The pattern will include the BEGIN_TEST_ROW and BEGIN_TEST_COL, but exclude the END_TEST_ROW and END_TEST_COL.
//    It means the test row/column range is [BEGIN_TEST_ROW, END_TEST_ROW) and [BEGIN_TEST_COL, END_TEST_COL).
//
////////////////////////////////////////////////////////////////////////

// Uncomment to activate the test pattern
`define ROW_MAJOR_PATTERN
// `define ROW_MAJOR_BANK_BURST_PATTERN
// `define COL_MAJOR_PATTERN
// `define COL_MAJOR_BANK_BURST_PATTERN
// `define REVERSE_ROW_MAJOR_PATTERN
// `define ALL_SAME_ADDR_PATTERN
// `define RAW_INTERLEAVE_PATTERN

// Definition Settings
`ifdef ROW_MAJOR_PATTERN
    `define BEGIN_TEST_ROW 0
    `define END_TEST_ROW   256
    `define BEGIN_TEST_COL 0
    `define END_TEST_COL 16
    `define TEST_ROW_STRIDE 1 // Must be power of 2
    `define TEST_COL_STRIDE 1 // Must be power of 2
    `define BANK_BUSRT_LENGTH 1 // Useless and it should be 1
`elsif ROW_MAJOR_BANK_BURST_PATTERN
    `define BEGIN_TEST_ROW 0
    `define END_TEST_ROW   16
    `define BEGIN_TEST_COL 0
    `define END_TEST_COL 4
    `define TEST_ROW_STRIDE 1 // Must be power of 2
    `define TEST_COL_STRIDE 1 // Must be power of 2
    `define BANK_BUSRT_LENGTH 4 // COL_LENGTH must be a multiple of (BANK_BUSRT_LENGTH * TEST_COL_STRIDE)
`elsif COL_MAJOR_PATTERN
	`define BEGIN_TEST_ROW 0
	`define END_TEST_ROW   16
	`define BEGIN_TEST_COL 0
	`define END_TEST_COL 16
	`define TEST_ROW_STRIDE 1 // Must be power of 2
	`define TEST_COL_STRIDE 1 // Must be power of 2
    `define BANK_BUSRT_LENGTH 1 // Useless and it should be 1
`elsif COL_MAJOR_BANK_BURST_PATTERN
	`define BEGIN_TEST_ROW 24
	`define END_TEST_ROW   68
	`define BEGIN_TEST_COL 0
	`define END_TEST_COL 16
	`define TEST_ROW_STRIDE 4 // Must be power of 2
	`define TEST_COL_STRIDE 1 // Must be power of 2
    `define BANK_BUSRT_LENGTH 11 // ROW_LENGTH must be a multiple of (BANK_BUSRT_LENGTH * TEST_ROW_STRIDE)
`elsif REVERSE_ROW_MAJOR_PATTERN
	`define BEGIN_TEST_ROW 65504
	`define END_TEST_ROW   65536 // Maximum of END_TEST_ROW = 65536
	`define BEGIN_TEST_COL 0
	`define END_TEST_COL 16
	`define TEST_ROW_STRIDE 1 // Must be power of 2
	`define TEST_COL_STRIDE 8 // Must be power of 2
    `define BANK_BUSRT_LENGTH 1 // Useless and it should be 1
`elsif ALL_SAME_ADDR_PATTERN
	`define BEGIN_TEST_ROW 0
	`define END_TEST_ROW   128
	`define BEGIN_TEST_COL 0
	`define END_TEST_COL 16
	`define TEST_ROW_STRIDE 1 // Useless for this pattern
	`define TEST_COL_STRIDE 1 // Useless for this pattern
    `define BANK_BUSRT_LENGTH 1 // Useless and it should be 1
`elsif RAW_INTERLEAVE_PATTERN
	`define BEGIN_TEST_ROW 0
	`define END_TEST_ROW   16
	`define BEGIN_TEST_COL 0
	`define END_TEST_COL 16
	`define TEST_ROW_STRIDE 1 // Useless for this pattern
	`define TEST_COL_STRIDE 1 // Useless for this pattern
    `define BANK_BUSRT_LENGTH 1 // Useless and it should be 1
`endif

`define ROW_LENGTH (`END_TEST_ROW-`BEGIN_TEST_ROW)
`define COL_LENGTH (`END_TEST_COL-`BEGIN_TEST_COL)

`ifdef ALL_SAME_ADDR_PATTERN
	`define TOTAL_READ_CMD (`ROW_LENGTH * `COL_LENGTH )
`elsif RAW_INTERLEAVE_PATTERN
    `define TOTAL_READ_CMD (`ROW_LENGTH * `COL_LENGTH )
`else
	`define TOTAL_READ_CMD (`ROW_LENGTH * `COL_LENGTH )/(`TEST_ROW_STRIDE * `TEST_COL_STRIDE ) * `TOTAL_BANK
`endif

// read + write
`define TOTAL_WRITE_CMD `TOTAL_READ_CMD
`define TOTAL_CMD `TOTAL_WRITE_CMD + `TOTAL_READ_CMD

module PATTERN(
                i_clk,
                i_clk2,
                i_rst_n,

                // request channel
                i_command_valid,
                i_command,
                i_write_data,
                o_controller_ready,

                // read data channel
                o_read_data_valid,
                o_read_data
);

`include "2048Mb_ddr3_parameters.vh"

output logic i_clk;
output logic i_clk2;
output logic i_rst_n;

// request channel IO port
output logic i_command_valid;
output frontend_command_t i_command;
output logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] i_write_data;
input logic o_controller_ready;

// read data channel IO port
input logic o_read_data_valid;
input logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] o_read_data;

//----------------------------------------------------//
//                    Declaration                     //
//----------------------------------------------------//
frontend_command_t command_table [`TOTAL_CMD*2-1:0];
frontend_command_t command_temp;
frontend_command_t command_table_out;

logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] write_data_table[`TOTAL_CMD*2-1:0];
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] write_data_temp ;

logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] mem[`TOTAL_ROW-1:0][`TOTAL_COL-1:0][`TOTAL_BANK-1:0];
logic [`GLOBAL_CONTROLLER_WORD_SIZE-1:0] mem_back[`TOTAL_ROW-1:0][`TOTAL_COL-1:0][`TOTAL_BANK-1:0];

logic [ `ROW_BITS-1:0]   row_addr;
logic [ `COL_BITS-1:0]   col_addr;
logic [`BANK_BITS-1:0]  bank_addr;
// for bank burst pattern
logic [ `COL_BITS-1:0]  burst_cnt;

logic all_data_read_f;

real CYCLE = `CLK_DEFINE;

integer index;
integer write_data_index;
integer iteration_times;
integer row, col, bank;
integer burst;
integer begin_col_temp;
integer begin_row_temp;
// pattern generation
integer write_data_count;
integer cmd_count;
// check data
integer read_data_count;
// report
integer total_cmd_count;
integer error_count;

integer begin_test_row;
integer end_test_row;
integer begin_test_col;
integer end_test_col;
integer test_row_stride;
integer test_col_stride;
// bank burst length: consecutive read/write to the same bank
integer bank_burst_length;

integer row_length;
integer col_length;

//----------------------------------------------------//
//                   CLOCK SETTING                    //
//----------------------------------------------------//
always #(`CLK_DEFINE/2.0) i_clk = ~i_clk;
always #(`CLK_DEFINE/4.0) i_clk2 = ~i_clk2;

//----------------------------------------------------//
//                   Initial Block                    //
//----------------------------------------------------//
// For different test patterns, share the same steps as shown below
// 1. Initialization :
//    Stall the clock and intialize all integers.
// 2. Check Definition :
//    Check the definition whether it is valid or not.
// 3. Pattern Generation :
//    Record the write and read command, and also the data should be read in mem array.
// 4. Insert Reset Signal
// 5. Perform the test pattern and Wait until all data are read :
//    Issue the command to the controller.
// 6. Check MEM and MEM_BACK
//    Check the read data from the controller with the data in mem array.
// 7. Report the result

initial
begin
    Check_Pattern_Definiton;
    Initialization;
    Check_Definition_Validity;
    $display("Total number of commands to test: %d",total_cmd_count);
    `ifdef ROW_MAJOR_PATTERN
        $display("===================================================");
        $display("=        Start to Create ROW MAJOR Pattern        =");
        $display("===================================================");
        // Record the write command
        for(row = begin_test_row; row < end_test_row; row = row + test_row_stride) begin
            for(col = begin_test_col; col < end_test_col; col = col + test_col_stride) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    command_temp.op_type = OP_WRITE;
                    command_temp.data_type = DATA_TYPE_WEIGHTS;
                    command_temp.row_addr = row;
                    command_temp.col_addr = col;
                    command_temp.bank_addr = bank;
                    command_table[cmd_count] = command_temp;

                    write_data_table[write_data_count] = row*16*16 + col*16 + bank;
                    mem[row][col][bank] = write_data_table[write_data_count];

                    cmd_count = cmd_count + 1;
                    write_data_count = write_data_count + 1;
                end
            end
        end
        // Record the read command
        for(row = begin_test_row; row < end_test_row; row = row + test_row_stride) begin
            for(col = begin_test_col; col < end_test_col; col = col + test_col_stride) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    command_temp.op_type = OP_READ;
                    command_temp.data_type = DATA_TYPE_WEIGHTS;
                    command_temp.row_addr = row;
                    command_temp.col_addr = col;
                    command_temp.bank_addr = bank;
                    command_table[cmd_count] = command_temp;

                    cmd_count = cmd_count + 1;
                end
            end
        end
        $display("========================================");
        $display("=       Pattern Gernation Done !!      =");
        $display("========================================");

        // Insert Reset Signal
        repeat(10) @(negedge i_clk);
        i_rst_n = 0;
        repeat(100) @(negedge i_clk);
        i_rst_n = 1;

        // Perform the test pattern and Wait until all data are read
        wait(all_data_read_f);

        // Check MEM and MEM_BACK
        for(row = begin_test_row; row < end_test_row; row = row + test_row_stride) begin
            for(col = begin_test_col; col < end_test_col; col = col + test_col_stride) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    if(mem[row][col][bank] != mem_back[row][col][bank])begin
                        $display("mem[%2d][%2d][%2d] ACCESS FAIL ! , mem=%128h , mem_back=%128h", row, col, bank, mem[row][col][bank], mem_back[row][col][bank]);
                        error_count = error_count + 1;
                    end else begin
                        $display("mem[%2d][%2d][%2d] ACCESS SUCCESS ! ", row, col, bank);
                    end
                end
            end
        end
    `elsif ROW_MAJOR_BANK_BURST_PATTERN
        $display("===================================================");
        $display("=  Start to Create ROW MAJOR BANK BURST Pattern   =");
        $display("===================================================");
        // Record the write command
        for(row = begin_test_row; row < end_test_row; row = row + test_row_stride) begin
            for(iteration_times = 0; iteration_times < col_length/bank_burst_length/test_col_stride; iteration_times = iteration_times + 1) begin
                // Calculate the begin column address for each iteration
                begin_col_temp = iteration_times * bank_burst_length * test_col_stride + begin_test_col;
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1)begin
                    for(burst = 0; burst < bank_burst_length; burst = burst + 1) begin
                        // Calculate the column address for each burst
                        col = begin_col_temp + burst * test_col_stride;

                        command_temp.op_type = OP_WRITE;
                        command_temp.data_type = DATA_TYPE_WEIGHTS;
                        command_temp.row_addr = row;
                        command_temp.col_addr = col;
                        command_temp.bank_addr = bank;
                        command_table[cmd_count] = command_temp;

                        write_data_table[write_data_count] = row*16*16 + col*16 + bank;
                        mem[row][col][bank] = write_data_table[write_data_count];

                        cmd_count = cmd_count + 1;
                        write_data_count = write_data_count + 1;
                    end
                end
            end
        end
        // Record the read command
        for(row = begin_test_row; row < end_test_row; row = row + test_row_stride) begin
            for(iteration_times = 0; iteration_times < col_length/bank_burst_length/test_col_stride; iteration_times = iteration_times + 1) begin
                // Calculate the begin column address for each iteration
                begin_col_temp = iteration_times * bank_burst_length * test_col_stride + begin_test_col;
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1)begin
                    for(burst = 0; burst < bank_burst_length; burst = burst + 1) begin
                        // Calculate the column address for each burst
                        col = begin_col_temp + burst * test_col_stride;

                        command_temp.op_type = OP_READ;
                        command_temp.data_type = DATA_TYPE_WEIGHTS;
                        command_temp.row_addr = row;
                        command_temp.col_addr = col;
                        command_temp.bank_addr = bank;
                        command_table[cmd_count] = command_temp;

                        cmd_count = cmd_count + 1;
                    end
                end
            end
        end
        $display("========================================");
        $display("=       Pattern Gernation Done !!      =");
        $display("========================================");

        // Insert Reset Signal
        repeat(10) @(negedge i_clk);
        i_rst_n = 0;
        repeat(100) @(negedge i_clk);
        i_rst_n = 1;

        // Perform the test pattern and Wait until all data are read
        wait(all_data_read_f);

        // Check MEM and MEM_BACK
        for(row = begin_test_row; row < end_test_row; row = row + test_row_stride) begin
            for(iteration_times = 0; iteration_times < col_length/bank_burst_length/test_col_stride; iteration_times = iteration_times + 1) begin
                // Calculate the begin column address for each iteration
                begin_col_temp = iteration_times * bank_burst_length * test_col_stride + begin_test_col;
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1)begin
                    for(burst = 0; burst < bank_burst_length; burst = burst + 1) begin
                        // Calculate the column address for each burst
                        col = begin_col_temp + burst * test_col_stride;

                        if(mem[row][col][bank] != mem_back[row][col][bank])begin
                            $display("mem[%2d][%2d][%2d] ACCESS FAIL ! , mem=%128h , mem_back=%128h", row, col, bank, mem[row][col][bank], mem_back[row][col][bank]);
                            error_count = error_count + 1;
                        end else begin
                            $display("mem[%2d][%2d][%2d] ACCESS SUCCESS ! ", row, col, bank);
                        end
                    end
                end
            end
        end
    `elsif COL_MAJOR_PATTERN
        $display("===================================================");
        $display("=        Start to Create COL MAJOR Pattern        =");
        $display("===================================================");
        // Record the write command
        for(col = begin_test_col; col < end_test_col; col = col + test_col_stride) begin
            for(row = begin_test_row; row < end_test_row; row = row + test_row_stride) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    command_temp.op_type = OP_WRITE;
                    command_temp.data_type = DATA_TYPE_WEIGHTS;
                    command_temp.row_addr = row;
                    command_temp.col_addr = col;
                    command_temp.bank_addr = bank;
                    command_table[cmd_count] = command_temp;

                    write_data_table[write_data_count] = row*16*16 + col*16 + bank;
                    mem[row][col][bank] = write_data_table[write_data_count];

                    cmd_count = cmd_count + 1;
                    write_data_count = write_data_count + 1;
                end
            end
        end
        // Record the read command
        for(col = begin_test_col; col < end_test_col; col = col + test_col_stride) begin
            for(row = begin_test_row; row < end_test_row; row = row + test_row_stride) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    command_temp.op_type = OP_READ;
                    command_temp.data_type = DATA_TYPE_WEIGHTS;
                    command_temp.row_addr = row;
                    command_temp.col_addr = col;
                    command_temp.bank_addr = bank;
                    command_table[cmd_count] = command_temp;

                    cmd_count = cmd_count + 1;
                end
            end
        end
        $display("========================================");
        $display("=       Pattern Gernation Done !!      =");
        $display("========================================");

        // Insert Reset Signal
        repeat(10) @(negedge i_clk);
        i_rst_n = 0;
        repeat(100) @(negedge i_clk);
        i_rst_n = 1;

        // Perform the test pattern and Wait until all data are read
        wait(all_data_read_f);

        // Check MEM and MEM_BACK
        for(col = begin_test_col; col < end_test_col; col = col + test_col_stride) begin
            for(row = begin_test_row; row < end_test_row; row = row + test_row_stride) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    if(mem[row][col][bank] != mem_back[row][col][bank])begin
                        $display("mem[%2d][%2d][%2d] ACCESS FAIL ! , mem=%128h , mem_back=%128h", row, col, bank, mem[row][col][bank], mem_back[row][col][bank]);
                        error_count = error_count + 1;
                    end else begin
                        $display("mem[%2d][%2d][%2d] ACCESS SUCCESS ! ", row, col, bank);
                    end
                end
            end
        end
    `elsif COL_MAJOR_BANK_BURST_PATTERN
        $display("===================================================");
        $display("=  Start to Create COL MAJOR BANK BURST Pattern   =");
        $display("===================================================");
        // Record the write command
        for(col = begin_test_col; col < end_test_col; col = col + test_col_stride) begin
            for(iteration_times = 0; iteration_times < row_length/bank_burst_length/test_row_stride; iteration_times = iteration_times + 1) begin
                // Calculate the begin row address for each iteration
                begin_row_temp = iteration_times * bank_burst_length * test_row_stride + begin_test_row;
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1)begin
                    for(burst = 0; burst < bank_burst_length; burst = burst + 1) begin
                        // Calculate the row address for each burst
                        row = begin_row_temp + burst * test_row_stride;

                        command_temp.op_type = OP_WRITE;
                        command_temp.data_type = DATA_TYPE_WEIGHTS;
                        command_temp.row_addr = row;
                        command_temp.col_addr = col;
                        command_temp.bank_addr = bank;
                        command_table[cmd_count] = command_temp;

                        write_data_table[write_data_count] = row*16*16 + col*16 + bank;
                        mem[row][col][bank] = write_data_table[write_data_count];

                        cmd_count = cmd_count + 1;
                        write_data_count = write_data_count + 1;
                    end
                end
            end
        end
        // Record the read command
        for(col = begin_test_col; col < end_test_col; col = col + test_col_stride) begin
            for(iteration_times = 0; iteration_times < row_length/bank_burst_length/test_row_stride; iteration_times = iteration_times + 1) begin
                // Calculate the begin row address for each iteration
                begin_row_temp = iteration_times * bank_burst_length * test_row_stride + begin_test_row;
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1)begin
                    for(burst = 0; burst < bank_burst_length; burst = burst + 1) begin
                        // Calculate the row address for each burst
                        row = begin_row_temp + burst * test_row_stride;

                        command_temp.op_type = OP_READ;
                        command_temp.data_type = DATA_TYPE_WEIGHTS;
                        command_temp.row_addr = row;
                        command_temp.col_addr = col;
                        command_temp.bank_addr = bank;
                        command_table[cmd_count] = command_temp;

                        cmd_count = cmd_count + 1;
                    end
                end
            end
        end
        $display("========================================");
        $display("=       Pattern Gernation Done !!      =");
        $display("========================================");

        // Insert Reset Signal
        repeat(10) @(negedge i_clk);
        i_rst_n = 0;
        repeat(100) @(negedge i_clk);
        i_rst_n = 1;

        // Perform the test pattern and Wait until all data are read
        wait(all_data_read_f);

        // Check MEM and MEM_BACK
        for(col = begin_test_col; col < end_test_col; col = col + test_col_stride) begin
            for(iteration_times = 0; iteration_times < row_length/bank_burst_length/test_row_stride; iteration_times = iteration_times + 1) begin
                // Calculate the begin row address for each iteration
                begin_row_temp = iteration_times * bank_burst_length * test_row_stride + begin_test_row;
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1)begin
                    for(burst = 0; burst < bank_burst_length; burst = burst + 1) begin
                        // Calculate the row address for each burst
                        row = begin_row_temp + burst * test_row_stride;

                        if(mem[row][col][bank] != mem_back[row][col][bank])begin
                            $display("mem[%2d][%2d][%2d] ACCESS FAIL ! , mem=%128h , mem_back=%128h", row, col, bank, mem[row][col][bank], mem_back[row][col][bank]);
                            error_count = error_count + 1;
                        end else begin
                            $display("mem[%2d][%2d][%2d] ACCESS SUCCESS ! ", row, col, bank);
                        end
                    end
                end
            end
        end
    `elsif REVERSE_ROW_MAJOR_PATTERN
        $display("===================================================");
        $display("=    Start to Create REVERSE ROW MAJOR Pattern    =");
        $display("===================================================");
        // Record the write command
        for(row = end_test_row-test_row_stride; row >= begin_test_row; row = row - test_row_stride) begin
            for(col = end_test_col-test_col_stride; col >= begin_test_col; col = col - test_col_stride) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    command_temp.op_type = OP_WRITE;
                    command_temp.data_type = DATA_TYPE_WEIGHTS;
                    command_temp.row_addr = row;
                    command_temp.col_addr = col;
                    command_temp.bank_addr = bank;
                    command_table[cmd_count] = command_temp;

                    // the number is designed to be recognized by users easily
                    write_data_table[write_data_count] = (row-begin_test_row)*16*16 + (col-begin_test_col)*16 + bank;
                    mem[row][col][bank] = write_data_table[write_data_count];

                    cmd_count = cmd_count + 1;
                    write_data_count = write_data_count + 1;
                end
            end
        end
        // Record the read command
        for(row = end_test_row-test_row_stride; row >= begin_test_row; row = row - test_row_stride) begin
            for(col = end_test_col-test_col_stride; col >= begin_test_col; col = col - test_col_stride) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    command_temp.op_type = OP_READ;
                    command_temp.data_type = DATA_TYPE_WEIGHTS;
                    command_temp.row_addr = row;
                    command_temp.col_addr = col;
                    command_temp.bank_addr = bank;
                    command_table[cmd_count] = command_temp;

                    cmd_count = cmd_count + 1;
                end
            end
        end
        $display("========================================");
        $display("=       Pattern Gernation Done !!      =");
        $display("========================================");

        // Insert Reset Signal
        repeat(10) @(negedge i_clk);
        i_rst_n = 0;
        repeat(100) @(negedge i_clk);
        i_rst_n = 1;

        // Perform the test pattern and Wait until all data are read
        wait(all_data_read_f);

        // Check MEM and MEM_BACK
        for(row = end_test_row-test_row_stride; row >= begin_test_row; row = row - test_row_stride) begin
            for(col = end_test_col-test_col_stride; col >= begin_test_col; col = col - test_col_stride) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    if(mem[row][col][bank] != mem_back[row][col][bank])begin
                        $display("mem[%2d][%2d][%2d] ACCESS FAIL ! , mem=%128h , mem_back=%128h", row, col, bank, mem[row][col][bank], mem_back[row][col][bank]);
                        error_count = error_count + 1;
                    end else begin
                        $display("mem[%2d][%2d][%2d] ACCESS SUCCESS ! ", row, col, bank);
                    end
                end
            end
        end
    `elsif ALL_SAME_ADDR_PATTERN
        $display("===================================================");
        $display("=     Start to Create ALL SAME ADDRESS Pattern    =");
        $display("===================================================");
        // Record the write command
        for(row = begin_test_row; row < end_test_row; row = row + 1) begin
            for(col = begin_test_col; col < end_test_col; col = col + 1) begin
                command_temp.op_type = OP_WRITE;
                command_temp.data_type = DATA_TYPE_WEIGHTS;
                command_temp.row_addr = 0;
                command_temp.col_addr = 0;
                command_temp.bank_addr = 0;
                command_table[cmd_count] = command_temp;

                write_data_table[write_data_count] = row*16*16 + col;
                mem[0][0][0] = write_data_table[write_data_count];

                cmd_count = cmd_count + 1;
                write_data_count = write_data_count + 1;
            end
        end
        // Record the read command
        for(row = begin_test_row; row < end_test_row; row = row + 1) begin
            for(col = begin_test_col; col < end_test_col; col = col + 1) begin
                command_temp.op_type = OP_READ;
                command_temp.data_type = DATA_TYPE_WEIGHTS;
                command_temp.row_addr = 0;
                command_temp.col_addr = 0;
                command_temp.bank_addr = 0;
                command_table[cmd_count] = command_temp;

                cmd_count = cmd_count + 1;
            end
        end
        $display("========================================");
        $display("=       Pattern Gernation Done !!      =");
        $display("========================================");

        // Insert Reset Signal
        repeat(10) @(negedge i_clk);
        i_rst_n = 0;
        repeat(100) @(negedge i_clk);
        i_rst_n = 1;

        // Perform the test pattern and Wait until all data are read
        wait(all_data_read_f);

        // Check MEM and MEM_BACK
        for(row = begin_test_row; row < end_test_row; row = row + 1) begin
            for(col = begin_test_col; col < end_test_col; col = col + 1) begin
                if(mem[0][0][0] != mem_back[0][0][0])begin
                    $display("mem[0][0][0] ACCESS FAIL ! , mem=%128h , mem_back=%128h", mem[row][col][bank], mem_back[row][col][bank]);
                    error_count = error_count + 1;
                end else begin
                    $display("mem[0][0][0] ACCESS SUCCESS ! ");
                end
            end
        end
    `elsif RAW_INTERLEAVE_PATTERN
        $display("===================================================");
        $display("=     Start to Create RAW INTERLEAVE Pattern      =");
        $display("===================================================");
        // Record the write command and read command continuously
        for(row = begin_test_row; row < end_test_row; row = row + 1) begin
            for(col = begin_test_col; col < end_test_col; col = col + 1) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    // Write command first
                    command_temp.op_type = OP_WRITE;
                    command_temp.data_type = DATA_TYPE_WEIGHTS;
                    command_temp.row_addr = row;
                    command_temp.col_addr = col;
                    command_temp.bank_addr = bank;
                    command_table[cmd_count] = command_temp;

                    write_data_table[write_data_count] = row*16*16 + col*16 + bank;
                    mem[row][col][bank] = write_data_table[write_data_count];

                    cmd_count = cmd_count + 1;
                    write_data_count = write_data_count + 1;

                    // Read command next
                    command_temp.op_type = OP_READ;
                    command_temp.data_type = DATA_TYPE_WEIGHTS;
                    command_temp.row_addr = row;
                    command_temp.col_addr = col;
                    command_temp.bank_addr = bank;
                    command_table[cmd_count] = command_temp;

                    cmd_count = cmd_count + 1;
                end
            end
        end
        $display("========================================");
        $display("=       Pattern Gernation Done !!      =");
        $display("========================================");

        // Insert Reset Signal
        repeat(10) @(negedge i_clk);
        i_rst_n = 0;
        repeat(100) @(negedge i_clk);
        i_rst_n = 1;

        // Perform the test pattern and Wait until all data are read
        wait(all_data_read_f);

        // Check MEM and MEM_BACK
        for(row = begin_test_row; row < end_test_row; row = row + 1) begin
            for(col = begin_test_col; col < end_test_col; col = col + 1) begin
                for(bank = 0; bank < `TOTAL_BANK; bank = bank + 1) begin
                    if(mem[row][col][bank] != mem_back[row][col][bank])begin
                        $display("mem[%2d][%2d][%2d] ACCESS FAIL ! , mem=%128h , mem_back=%128h", row, col, bank, mem[row][col][bank], mem_back[row][col][bank]);
                        error_count = error_count + 1;
                    end else begin
                        $display("mem[%2d][%2d][%2d] ACCESS SUCCESS ! ", row, col, bank);
                    end
                end
            end
        end
    `else
        $display("NOT DONE YET!!");
    `endif

    Report_Result;
end

//----------------------------------------------------//
//                  Input Pattern                     //
//----------------------------------------------------//
// i_command_valid
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n)begin
        i_command_valid <= 1;
    end else begin
        if(i_command_valid && o_controller_ready)begin
            if(index == `TOTAL_CMD-1)begin
                i_command_valid <= 0;
            end
            else begin
                i_command_valid <= 1;
            end
        end
    end
end

// i_command
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n)begin
        i_command <= command_table[0];
    end else begin
        if(i_command_valid && o_controller_ready)begin
            if(index == `TOTAL_CMD-1)begin
                i_command <= 0;
            end else begin
                i_command <= command_table[index+1];
            end
        end
    end
end

// i_write_data
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n)begin
        i_write_data <= write_data_table[0];
    end else begin
        if(i_command_valid && o_controller_ready && i_command.op_type == OP_WRITE)begin
            if(write_data_index >= `TOTAL_WRITE_CMD-1)begin
                i_write_data <= 0;
            end else begin
                i_write_data <= write_data_table[write_data_index+1];
            end
        end
    end
end

// index
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n)begin
        index <= 0;
    end else begin
        if(i_command_valid && o_controller_ready)begin
            index <= index + 1;
        end
    end
end
// write_data_index
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n)begin
        write_data_index <= 0;
    end else begin
        if(i_command_valid && o_controller_ready && i_command.op_type == OP_WRITE)begin
            write_data_index <= write_data_index + 1;
        end
    end
end

//----------------------------------------------------//
//                  MEM_BACK Related                  //
//----------------------------------------------------//
logic read_data_bandwidth_calculation_lock;
logic[31:0] read_cycles;
logic[31:0] idle_cycles;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n)begin
        read_data_bandwidth_calculation_lock <= 1'b1;
        read_cycles <= 0;
        idle_cycles <= 0;
    end else begin
        if(o_read_data_valid)begin
            read_data_bandwidth_calculation_lock <= 1'b0;
        end else if(all_data_read_f)begin
            read_data_bandwidth_calculation_lock <= 1'b1;
        end

        if(read_data_bandwidth_calculation_lock==1'b0)begin
            read_cycles <= read_cycles + 1;
            
            if(~o_read_data_valid)begin
                idle_cycles <= idle_cycles + 1;
            end

        end else begin
            read_cycles <= 0;
            idle_cycles <= idle_cycles;
        end
    end
end

// all_data_read_f
assign all_data_read_f = (read_data_count == `TOTAL_READ_CMD);

// read_data_count
always @(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n) begin
        read_data_count <= 0;
    end else begin
        if(o_read_data_valid) begin
            read_data_count <= read_data_count + 1;
        end
    end
end

// MEM_BACK
always @(posedge i_clk)begin
    if(o_read_data_valid) begin
        mem_back[row_addr][col_addr][bank_addr] <= o_read_data;
    end
end

// MEM_BACK address
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        `ifdef REVERSE_ROW_MAJOR_PATTERN
            row_addr <= end_test_row-test_row_stride;
        `else
            row_addr <= begin_test_row;
        `endif
    end else begin
        if(o_read_data_valid) begin
            `ifdef ROW_MAJOR_PATTERN
                if(col_addr == end_test_col - test_col_stride && bank_addr == `TOTAL_BANK-1)begin
                    row_addr <= row_addr + test_row_stride;
                end
            `elsif ROW_MAJOR_BANK_BURST_PATTERN
                if(col_addr == end_test_col - test_col_stride && bank_addr == `TOTAL_BANK-1)begin
                    row_addr <= row_addr + test_row_stride;
                end
            `elsif COL_MAJOR_PATTERN
                if(bank_addr == `TOTAL_BANK-1)begin
                    row_addr <= row_addr + test_row_stride;
                end
            `elsif COL_MAJOR_BANK_BURST_PATTERN
                if(burst_cnt == bank_burst_length-1)begin
                    if(bank_addr == `TOTAL_BANK-1)begin
                        if(row_addr == end_test_row - test_row_stride)begin
                            row_addr <= begin_test_row;
                        end else begin
                            row_addr <= row_addr + test_row_stride;
                        end
                    end else begin
                        row_addr <= row_addr - (bank_burst_length-1) * test_row_stride;
                    end
                end else begin
                    row_addr <= row_addr + test_row_stride;
                end
            `elsif REVERSE_ROW_MAJOR_PATTERN
                if(col_addr == begin_test_col && bank_addr == `TOTAL_BANK-1)begin
                    row_addr <= row_addr - test_row_stride;
                end
            `elsif ALL_SAME_ADDR_PATTERN
                if(col_addr == end_test_col - 1 && bank_addr == `TOTAL_BANK-1)begin
                    row_addr <= row_addr + 1;
                end
            `elsif RAW_INTERLEAVE_PATTERN
                if(col_addr == end_test_col - 1 && bank_addr == `TOTAL_BANK-1)begin
                    row_addr <= row_addr + 1;
                end
            `endif
        end
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        `ifdef REVERSE_ROW_MAJOR_PATTERN
            col_addr <= end_test_col-test_col_stride;
        `else
            col_addr <= begin_test_col;
        `endif
    end else begin
        if(o_read_data_valid) begin
            `ifdef ROW_MAJOR_PATTERN
                if(bank_addr == `TOTAL_BANK-1)begin
                    col_addr <= (col_addr + test_col_stride) % col_length;
                end
            `elsif ROW_MAJOR_BANK_BURST_PATTERN
                if(burst_cnt == bank_burst_length-1)begin
                    if(bank_addr == `TOTAL_BANK-1)begin
                        if(col_addr == end_test_col - test_col_stride)begin
                            col_addr <= begin_test_col;
                        end else begin
                            col_addr <= col_addr + test_col_stride;
                        end
                    end else begin
                        col_addr <= col_addr - (bank_burst_length-1) * test_col_stride;
                    end
                end else begin
                    col_addr <= col_addr + test_col_stride;
                end
            `elsif COL_MAJOR_PATTERN
                if(row_addr == end_test_row - test_row_stride && bank_addr == `TOTAL_BANK-1)begin
                    col_addr <= col_addr + test_col_stride;
                end
            `elsif COL_MAJOR_BANK_BURST_PATTERN
                if(row_addr == end_test_row - test_row_stride && bank_addr == `TOTAL_BANK-1)begin
                    col_addr <= col_addr + test_col_stride;
                end
            `elsif REVERSE_ROW_MAJOR_PATTERN
                if(bank_addr == `TOTAL_BANK-1)begin
                    col_addr <= (col_addr - test_col_stride) % col_length;
                end
            `elsif ALL_SAME_ADDR_PATTERN
                col_addr <= (col_addr + 1) % col_length;
            `elsif RAW_INTERLEAVE_PATTERN
                if(bank_addr == `TOTAL_BANK-1)begin
                    col_addr <= (col_addr + test_col_stride) % col_length;
                end
            // `else
                // col_addr <= (col_addr + test_col_stride) % col_length;
            `endif
        end
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        bank_addr <= 0;
    end else begin
        if(o_read_data_valid) begin
            `ifdef ROW_MAJOR_PATTERN
                bank_addr <= (bank_addr + 1) % `TOTAL_BANK;
            `elsif ROW_MAJOR_BANK_BURST_PATTERN
                if(burst_cnt == bank_burst_length-1)begin
                    bank_addr <= (bank_addr + 1) % `TOTAL_BANK;
                end else begin
                    bank_addr <= bank_addr;
                end
            `elsif COL_MAJOR_PATTERN
                bank_addr <= (bank_addr + 1) % `TOTAL_BANK;
            `elsif COL_MAJOR_BANK_BURST_PATTERN
                if(burst_cnt == bank_burst_length-1)begin
                    bank_addr <= (bank_addr + 1) % `TOTAL_BANK;
                end else begin
                    bank_addr <= bank_addr;
                end
            `elsif REVERSE_ROW_MAJOR_PATTERN
                bank_addr <= (bank_addr + 1) % `TOTAL_BANK;
            `elsif ALL_SAME_ADDR_PATTERN
                bank_addr <= 0;
            `elsif RAW_INTERLEAVE_PATTERN
                bank_addr <= (bank_addr + 1) % `TOTAL_BANK;
            `else
                bank_addr <= (bank_addr + 1) % `TOTAL_BANK;
            `endif
        end
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        burst_cnt <= 0;
    end else begin
        if(o_read_data_valid) begin
            // burst_cnt is only used for bank burst patterns
            `ifdef ROW_MAJOR_BANK_BURST_PATTERN
                if(burst_cnt == bank_burst_length - 1)begin
                    burst_cnt <= 0;
                end else begin
                    burst_cnt <= burst_cnt + 1;
                end
            `elsif COL_MAJOR_BANK_BURST_PATTERN
                if(burst_cnt == bank_burst_length - 1)begin
                    burst_cnt <= 0;
                end else begin
                    burst_cnt <= burst_cnt + 1;
                end
            `else
                burst_cnt <= 0;
            `endif
        end
    end
end
//----------------------------------------------------//
//                       OTHER                        //
//----------------------------------------------------//
// Check the definition of the test pattern
logic [`ROW_BITS-1:0] row_stride_1, row_stride_2;
logic [`ROW_BITS-1:0] row_stride_not_power_of_2;
logic [`COL_BITS-1:0] col_stride_1, col_stride_2;
logic [`COL_BITS-1:0] col_stride_not_power_of_2;
assign row_stride_1 = `TEST_ROW_STRIDE;
assign row_stride_2 = `TEST_ROW_STRIDE - 1;
assign row_stride_not_power_of_2 = row_stride_1 & row_stride_2;

assign col_stride_1 = `TEST_COL_STRIDE;
assign col_stride_2 = `TEST_COL_STRIDE - 1;
assign col_stride_not_power_of_2 = col_stride_1 & col_stride_2;

logic[31:0] latency_counter;
logic latency_counter_lock;

always @(posedge i_clk or negedge i_rst_n)
begin: LATENCY_CLOCK_LOCK
    if(!i_rst_n)
    begin
        latency_counter_lock <= 1;
    end
    else
    begin
        if(i_command_valid && o_controller_ready && latency_counter_lock)
        begin
            latency_counter_lock <= 1'b0;
        end
    end
end

always_ff@(posedge i_clk or negedge i_rst_n)
begin: LATENCY_COUNTER
	if(!i_rst_n)
    begin
		latency_counter<=1;
    end
	else if(latency_counter_lock==1'b0 && all_data_read_f == 1'b0)
    begin
		latency_counter<=latency_counter + 1;
    end

	if(latency_counter % 100000 == 0)
    begin
		$display("CLK TICK: %d",latency_counter);
	end
end

logic[15:0] stall_counter;
wire release_stall_f = stall_counter == 15;

always_ff@(posedge i_clk or negedge i_rst_n)
begin: STALL_COUNTER
	if(!i_rst_n)
    begin
		stall_counter <= 0;
	end
    else if(release_stall_f)
    begin
		stall_counter <= 0;
	end
    else
    begin
		stall_counter <= stall_counter + 1;
	end
end
//----------------------------------------------------//
//                       TASK                         //
//----------------------------------------------------//
task Check_Pattern_Definiton;
begin
    // If not activate any pattern
    `ifndef ROW_MAJOR_PATTERN
        `ifndef ROW_MAJOR_BANK_BURST_PATTERN
            `ifndef COL_MAJOR_PATTERN
                `ifndef COL_MAJOR_BANK_BURST_PATTERN
                    `ifndef REVERSE_ROW_MAJOR_PATTERN
                        `ifndef ALL_SAME_ADDR_PATTERN
                            `ifndef RAW_INTERLEAVE_PATTERN
                                $display("==========================================================================");
                                $display("=                       No pattern is activated !!                       =");
                                $display("=             Please uncomment the pattern you want to test !!           =");
                                $display("==========================================================================");
                                $finish;
                            `endif
                        `endif
                    `endif
                `endif
            `endif
        `endif
    `endif
end endtask

task Initialization;
begin
    i_clk = 1;
    i_clk2 = 1;
    i_rst_n = 1;
    i_command_valid = 0;
    i_command = 0;
    i_write_data = 0;

    iteration_times = 0;
    row = 0; col = 0; bank = 0;
    burst = 0;
    begin_col_temp = 0;
    begin_row_temp = 0;

    cmd_count = 0 ;
    write_data_count = 0;
    read_data_count = 0;

    total_cmd_count = `TOTAL_CMD;
    error_count = 0 ;

    begin_test_row = `BEGIN_TEST_ROW;
    end_test_row = `END_TEST_ROW;
    begin_test_col = `BEGIN_TEST_COL;
    end_test_col = `END_TEST_COL;
    test_row_stride = `TEST_ROW_STRIDE;
    test_col_stride = `TEST_COL_STRIDE;
    bank_burst_length = `BANK_BUSRT_LENGTH;

    row_length = `ROW_LENGTH;
    col_length = `COL_LENGTH;
end endtask

task Check_Definition_Validity;
begin
    // CHECK ROW DEFINITION
    if (begin_test_row < 0 || begin_test_row > 65536) begin
        $display("==========================================================================");
        $display("=         BEGIN_TEST_ROW should be in the range [0, 65536] !!          =");
        $display("==========================================================================");
        $finish;
    end
    if (end_test_row < 0 || end_test_row > 65536) begin
        $display("==========================================================================");
        $display("=          END_TEST_ROW should be in the range [0, 65536] !!           =");
        $display("==========================================================================");
        $finish;
    end
    if (begin_test_row > end_test_row) begin
        $display("==========================================================================");
        $display("=          BEGIN_TEST_ROW cannot be larger than END_TEST_ROW !!          =");
        $display("==========================================================================");
        $finish;
    end
    // CHECK COL DEFINITION
    if (begin_test_col < 0 || begin_test_col > 16) begin
        $display("==========================================================================");
        $display("=          BEGIN_TEST_COL should be in the range [0, 16] !!              =");
        $display("==========================================================================");
        $finish;
    end
    if (end_test_col < 0 || end_test_col > 16) begin
        $display("==========================================================================");
        $display("=            END_TEST_COL should be in the range [0, 16] !!              =");
        $display("==========================================================================");
        $finish;
    end
    if (begin_test_col > end_test_col) begin
        $display("==========================================================================");
        $display("=          BEGIN_TEST_COL cannot be larger than END_TEST_COL !!          =");
        $display("==========================================================================");
        $finish;
    end

    // CHECK STRIDE DEFINITION
    if (test_row_stride < 1 || test_row_stride > 65536) begin
        $display("==========================================================================");
        $display("=          TEST_ROW_STRIDE should be in the range [1, 65536] !!        =");
        $display("==========================================================================");
        $finish;
    end
    if (row_length % test_row_stride != 0) begin
        $display("==========================================================================");
        $display("=          ROW_LENGTH must be a multiple of TEST_ROW_STRIDE !!           =");
        $display("==========================================================================");
        $finish;
    end
    if (row_stride_not_power_of_2 != 'b0) begin
        $display("==========================================================================");
        $display("=                 TEST_ROW_STRIDE must be a power of 2 !!                =");
        $display("==========================================================================");
        $finish;
    end

    if (test_col_stride < 1 || test_col_stride > 16) begin
        $display("==========================================================================");
        $display("=           TEST_COL_STRIDE should be in the range [1, 16] !!            =");
        $display("==========================================================================");
        $finish;
    end
    if (col_length % test_col_stride != 0) begin
        $display("==========================================================================");
        $display("=          COL_LENGTH must be a multiple of TEST_COL_STRIDE !!            =");
        $display("==========================================================================");
        $finish;
    end
    if (col_stride_not_power_of_2 != 'b0) begin
        $display("==========================================================================");
        $display("=                 TEST_COL_STRIDE must be a power of 2 !!                =");
        $display("==========================================================================");
        $finish;
    end

    `ifdef ROW_MAJOR_BANK_BURST_PATTERN
        // CHECK BANK BURST LENGTH DEFINITION
        if (bank_burst_length < 1 || bank_burst_length > 16) begin
            $display("==========================================================================");
            $display("=          BANK_BUSRT_LENGTH must be in the range [1, 16] !!             =");
            $display("==========================================================================");
            $finish;
        end
        if ((col_length % (bank_burst_length * test_col_stride)) != 0) begin
            $display("==============================================================================================");
            $display("=        column length must be a multiple of (BANK_BURST_LENGTH * TEST_COL_STRIDE) !!        =");
            $display("==============================================================================================");
            $finish;
        end
    `elsif COL_MAJOR_BANK_BURST_PATTERN
        // CHECK BANK BURST LENGTH DEFINITION
        if (bank_burst_length < 1 || bank_burst_length > 16) begin
            $display("==========================================================================");
            $display("=          BANK_BUSRT_LENGTH must be in the range [1, 16] !!             =");
            $display("==========================================================================");
            $finish;
        end
        if ((row_length % (bank_burst_length * test_row_stride)) != 0) begin
            $display("==============================================================================================");
            $display("=          row length must be a multiple of (BANK_BURST_LENGTH * TEST_ROW_STRIDE) !!         =");
            $display("==============================================================================================");
            $finish;
        end
    `endif
end endtask

task Report_Result;
begin
    $display("=====================================") ;
    $display(" TOTAL design read data: %12d",read_data_count);
    $display("=====================================") ;
    $display(" TOTAL  read data error: %12d",error_count);
    $display("=====================================") ;
    $display("      Read Data Count: %d",read_data_count);
    $display("Total Read Data Count: %d",`TOTAL_READ_CMD);
    $display("Total Memory Simulation cycles:%d",latency_counter);
    // Total read data bandwidth = (read_data_count)/read cycles
    $display("Total Average Read Data Bandwidth: %d GB/s",((read_data_count*1024)/8)/read_cycles);
    $display("Total Average Idle Cycles: %d",idle_cycles);
    // Total idle cycles = (idle cycles)/read cycles
    $display("Total Average Idle Cycles: %d Percents",((idle_cycles*100)/read_cycles));
    #(10);
    $finish;
end endtask

initial begin
    #(`CLK_DEFINE * 500000);
    $display("=====================================") ;
    $display(" MAX SIMULATION CYCLES REACHED") ;
    $display("=====================================") ;
    $finish;
end



endmodule