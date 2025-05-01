#======================================================
#
# Synopsys Synthesis Scripts (Design Vision dctcl mode)
#
#======================================================
#======================================================
# (A) Global Parameters
#======================================================
set DESIGN "DRAM_Controller"
set CYCLE 1
set CYCLE2 0.5
set INPUT_DLY [expr 0.5*$CYCLE]
set OUTPUT_DLY [expr 0.5*$CYCLE]

set INPUT_DLY2 [expr 0.5*$CYCLE2]
set OUTPUT_DLY2 [expr 0.5*$CYCLE2]

#======================================================
# (B) Read RTL Code
#======================================================
# (B-1) analyze + elaborate
set hdlin_auto_save_templates TRUE
analyze -f sverilog {define.sv Usertype.sv frontend_cmd_definition_pkg.sv DRAM_Controller.sv }
elaborate $DESIGN

# (B-2) read_sverilog
#read_sverilog $DESIGN\.v

# (B-3) set current design
current_design $DESIGN
link

#======================================================
#  (C) Global Setting
#======================================================
set_wire_load_mode top
# set_operating_conditions -max WCCOM -min BCCOM
# set_wire_load_model -name umc18_wl10 -library slow

#======================================================
#  (D) Set Design Constraints
#======================================================
# (D-1) Setting Clock Constraints
create_clock -name clk -period $CYCLE [get_ports clk]
create_clock -name clk2 -period $CYCLE2 [get_ports clk2]
# clk1
set_dont_touch_network             [get_clocks clk]
set_fix_hold                       [get_clocks clk]
set_clock_uncertainty       0.1    [get_clocks clk]

# clk2
set_dont_touch_network             [get_clocks clk2]
set_fix_hold                       [get_clocks clk2]
set_clock_uncertainty       0.1    [get_clocks clk2]

set_input_transition        0.5    [all_inputs]
set_clock_transition        0.1    [all_clocks]

# (D-2) Setting in/out Constraints for signals driven by clk1
# CLK
set_input_delay   -max  $INPUT_DLY            -clock clk   [get_ports controller_valid] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY            -clock clk   [get_ports controller_valid] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY            -clock clk   [get_ports command] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY            -clock clk   [get_ports command] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY            -clock clk   [get_ports write_data] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY            -clock clk   [get_ports write_data] ;  # hold   time check

set_output_delay  -max  $OUTPUT_DLY           -clock clk   [get_ports controller_ready] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY           -clock clk   [get_ports controller_ready] ; # hold   time check

set_output_delay  -max  $OUTPUT_DLY           -clock clk   [get_ports read_data] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY           -clock clk   [get_ports read_data] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY           -clock clk   [get_ports read_data_valid] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY           -clock clk   [get_ports read_data_valid] ; # hold   time check

# # NEG CLK
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports rst_n_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports rst_n_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports rst_n_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports rst_n_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports rst_n_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports rst_n_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports rst_n_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports rst_n_3] ; # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cke_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cke_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cke_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cke_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cke_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cke_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cke_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cke_3] ; # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cs_n_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cs_n_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cs_n_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cs_n_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cs_n_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cs_n_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cs_n_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cs_n_3] ; # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ras_n_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ras_n_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ras_n_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ras_n_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ras_n_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ras_n_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ras_n_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ras_n_3] ; # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cas_n_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cas_n_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cas_n_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cas_n_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cas_n_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cas_n_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports cas_n_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports cas_n_3] ; # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports we_n_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports we_n_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports we_n_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports we_n_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports we_n_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports we_n_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports we_n_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports we_n_3] ; # hold   time check


set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dm_tdqs_in_0] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dm_tdqs_in_0] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dm_tdqs_in_1] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dm_tdqs_in_1] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dm_tdqs_in_2] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dm_tdqs_in_2] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dm_tdqs_in_3] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dm_tdqs_in_3] ;  # hold   time check


set_output_delay -max  $OUTPUT_DLY2           -clock clk2   [get_ports dm_tdqs_out_0] ; # set_up time check
set_output_delay -min  $OUTPUT_DLY2           -clock clk2   [get_ports dm_tdqs_out_0] ; # hold   time check
set_output_delay -max  $OUTPUT_DLY2           -clock clk2   [get_ports dm_tdqs_out_1] ; # set_up time check
set_output_delay -min  $OUTPUT_DLY2           -clock clk2   [get_ports dm_tdqs_out_1] ; # hold   time check
set_output_delay -max  $OUTPUT_DLY2           -clock clk2   [get_ports dm_tdqs_out_2] ; # set_up time check
set_output_delay -min  $OUTPUT_DLY2           -clock clk2   [get_ports dm_tdqs_out_2] ; # hold   time check
set_output_delay -max  $OUTPUT_DLY2           -clock clk2   [get_ports dm_tdqs_out_3] ; # set_up time check
set_output_delay -min  $OUTPUT_DLY2           -clock clk2   [get_ports dm_tdqs_out_3] ; # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ba_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ba_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ba_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ba_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ba_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ba_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ba_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ba_3] ; # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports addr_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports addr_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports addr_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports addr_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports addr_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports addr_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports addr_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports addr_3] ; # hold   time check


set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports data_in_0] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports data_in_0] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports data_in_1] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports data_in_1] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports data_in_2] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports data_in_2] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports data_in_3] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports data_in_3] ;  # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports data_out_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports data_out_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports data_out_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports data_out_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports data_out_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports data_out_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports data_out_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports data_out_3] ; # hold   time check


set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports data_all_in_0] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports data_all_in_0] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports data_all_in_1] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports data_all_in_1] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports data_all_in_2] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports data_all_in_2] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports data_all_in_3] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports data_all_in_3] ;  # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk   [get_ports data_all_out_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk   [get_ports data_all_out_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk   [get_ports data_all_out_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk   [get_ports data_all_out_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk   [get_ports data_all_out_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk   [get_ports data_all_out_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk   [get_ports data_all_out_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk   [get_ports data_all_out_3] ; # hold   time check


set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dqs_in_0] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dqs_in_0] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dqs_in_1] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dqs_in_1] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dqs_in_2] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dqs_in_2] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dqs_in_3] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dqs_in_3] ;  # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_out_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_out_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_out_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_out_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_out_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_out_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_out_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_out_3] ; # hold   time check


set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dqs_n_in_0] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dqs_n_in_0] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dqs_n_in_1] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dqs_n_in_1] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dqs_n_in_2] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dqs_n_in_2] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports dqs_n_in_3] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports dqs_n_in_3] ;  # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_n_out_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_n_out_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_n_out_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_n_out_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_n_out_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_n_out_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_n_out_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports dqs_n_out_3] ; # hold   time check


set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports tdqs_n_0] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports tdqs_n_0] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports tdqs_n_1] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports tdqs_n_1] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports tdqs_n_2] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports tdqs_n_2] ;  # hold   time check
set_input_delay   -max  $INPUT_DLY2            -clock clk2   [get_ports tdqs_n_3] ;  # set_up time check
set_input_delay   -min  $INPUT_DLY2            -clock clk2   [get_ports tdqs_n_3] ;  # hold   time check

set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports odt_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports odt_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports odt_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports odt_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports odt_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports odt_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports odt_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports odt_3] ; # hold   time check


set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ddr3_rw_0] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ddr3_rw_0] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ddr3_rw_1] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ddr3_rw_1] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ddr3_rw_2] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ddr3_rw_2] ; # hold   time check
set_output_delay  -max  $OUTPUT_DLY2           -clock clk2   [get_ports ddr3_rw_3] ; # set_up time check
set_output_delay  -min  $OUTPUT_DLY2           -clock clk2   [get_ports ddr3_rw_3] ; # hold   time check


set_input_delay 0 -clock clk clk
set_input_delay 0 -clock clk2 clk2
set_input_delay 0 -clock clk power_on_rst_n
#set_max_delay $CYCLE -from [all_inputs] -to [all_outputs]

# (D-3) Setting Design Environment
# set_driving_cell -library umc18io3v5v_slow -lib_cell P2C    -pin {Y}  [get_ports clk]
# set_driving_cell -library umc18io3v5v_slow -lib_cell P2C    -pin {Y}  [remove_from_collection [all_inputs] [get_ports clk]]
# set_load  [load_of "umc18io3v5v_slow/P8C/A"]       [all_outputs] ; # ~= 0.038
set_load 0.05 [all_outputs]

# (D-4) Setting DRC Constraint
#set_max_delay           0     ; # Optimize delay max effort
#set_max_area            0      ; # Optimize area max effort
# set_max_transition      3       [all_inputs]   ; # U18 LUT Max Transition Value
# set_max_capacitance     0.15    [all_inputs]   ; # U18 LUT Max Capacitance Value
# set_max_fanout          10      [all_inputs]
# set_dont_use slow/JKFF*
#set_dont_touch [get_cells core_reg_macro]
#set hdlin_ff_always_sync_set_reset true

# ================================== #
#  Multi cycle script for synthesis  #
# ================================== #
set_multicycle_path 2 -setup -from clk -to clk2 -end
set_multicycle_path 1 -hold  -from clk -to clk2 -end

set_multicycle_path 1 -setup -from clk2 -to clk -start
set_multicycle_path 0 -hold  -from clk2 -to clk -start



# (D-5) Report Clock skew
report_clock -skew clk
check_timing

#======================================================
#  (E) Optimization
#======================================================
uniquify
check_design > Report/$DESIGN\.check
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
set_fix_hold [all_clocks]
compile_ultra
# compile

#======================================================
#  (F) Output Reports
#======================================================
report_design  >  Report/$DESIGN\.design
report_resource >  Report/$DESIGN\.resource
report_timing -max_paths 3 >  Report/$DESIGN\.timing
report_area >  Report/$DESIGN\.area
report_power > Report/$DESIGN\.power
report_clock > Report/$DESIGN\.clock
report_port >  Report/$DESIGN\.port
report_power >  Report/$DESIGN\.power
#report_reference > Report/$DESIGN\.reference

#======================================================
#  (G) Change Naming Rule
#======================================================
set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule


#======================================================
#  (H) Output Results
#======================================================
set verilogout_higher_designs_first true
write -format verilog -output Netlist/$DESIGN\_SYN.v -hierarchy
write -format ddc     -hierarchy -output $DESIGN\_SYN.ddc
write_sdf -version 3.0 -context verilog -load_delay cell Netlist/$DESIGN\_SYN.sdf -significant_digits 6
write_sdc Netlist/$DESIGN\_SYN.sdc

#======================================================
#  (I) Finish and Quit
#======================================================
report_area
report_timing
exit
