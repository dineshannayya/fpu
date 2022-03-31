###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 20.0000 [get_ports {clk}]

set_clock_transition 0.1500 [all_clocks]
set_clock_uncertainty -setup 0.2500 [all_clocks]
set_clock_uncertainty -hold 0.2500 [all_clocks]

set_propagated_clock [all_clocks]


set ::env(SYNTH_TIMING_DERATE) 0.05
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]


set_input_delay -max 5.0000 -clock [get_clocks {wb_clk}] -add_delay [get_ports {wb_rst_n}]

#Wishbone DMEM
set_input_delay -max 4.5000 -clock [get_clocks {clk}] -add_delay [get_ports {cmd[*]}]
set_input_delay -max 4.5000 -clock [get_clocks {clk}] -add_delay [get_ports {din1[*]}]
set_input_delay -max 4.5000 -clock [get_clocks {clk}] -add_delay [get_ports {din2[*]}]
set_input_delay -max 4.5000 -clock [get_clocks {clk}] -add_delay [get_ports {dval}]

set_input_delay -min 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {cmd[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {din1[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {din2[*]}]
set_input_delay -min 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {dval}]

set_output_delay -max 4.5000 -clock [get_clocks {clk}] -add_delay [get_ports {result[*]}]
set_output_delay -max 4.5000 -clock [get_clocks {clk}] -add_delay [get_ports {rdy}]

set_output_delay -min 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {result[*]}]
set_output_delay -min 2.0000 -clock [get_clocks {clk}] -add_delay [get_ports {rdy}]

set_false_path -from [get_ports {rst_n}]
###############################################################################
# Environment
###############################################################################
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_8 -pin $::env(SYNTH_DRIVING_CELL_PIN) [all_inputs]
set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

###############################################################################
# Design Rules
###############################################################################
