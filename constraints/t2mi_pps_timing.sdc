# =============================================================================
# T2MI PPS Generator Timing Constraints
# =============================================================================
# Description: Detailed timing constraints for T2MI PPS generator
# Target: Lattice LFE5U-25F-6BG256C
# Format: SDC (Synopsys Design Constraints)
# =============================================================================

# =============================================================================
# Clock Definitions
# =============================================================================

# Primary system clock - 100 MHz
create_clock -name clk_100mhz -period 10.000 [get_ports clk_100mhz]

# T2MI input clock - 27 MHz
create_clock -name t2mi_clk -period 37.037 [get_ports t2mi_clk]

# SiT5503 reference clock - 10 MHz (if used)
create_clock -name sit5503_clk -period 100.000 [get_ports sit5503_clk]

# =============================================================================
# Clock Uncertainty and Jitter
# =============================================================================

# Add clock uncertainty for setup/hold analysis
set_clock_uncertainty -setup 0.100 [get_clocks clk_100mhz]
set_clock_uncertainty -hold  0.050 [get_clocks clk_100mhz]

set_clock_uncertainty -setup 0.200 [get_clocks t2mi_clk]
set_clock_uncertainty -hold  0.100 [get_clocks t2mi_clk]

# Add jitter specification for high-precision oscillator
set_clock_uncertainty -setup 0.020 [get_clocks sit5503_clk]
set_clock_uncertainty -hold  0.010 [get_clocks sit5503_clk]

# =============================================================================
# Clock Groups and Domain Crossing
# =============================================================================

# Define asynchronous clock groups
set_clock_groups -asynchronous \
    -group [get_clocks clk_100mhz] \
    -group [get_clocks t2mi_clk] \
    -group [get_clocks sit5503_clk]

# =============================================================================
# Input/Output Delays
# =============================================================================

# T2MI input constraints
set_input_delay -clock t2mi_clk -max 5.0 [get_ports {t2mi_data[*]}]
set_input_delay -clock t2mi_clk -min 1.0 [get_ports {t2mi_data[*]}]

set_input_delay -clock t2mi_clk -max 5.0 [get_ports t2mi_valid]
set_input_delay -clock t2mi_clk -min 1.0 [get_ports t2mi_valid]

set_input_delay -clock t2mi_clk -max 5.0 [get_ports t2mi_sync]
set_input_delay -clock t2mi_clk -min 1.0 [get_ports t2mi_sync]

# PPS output constraints - Critical timing
set_output_delay -clock clk_100mhz -max 2.0 [get_ports pps_out]
set_output_delay -clock clk_100mhz -min 0.5 [get_ports pps_out]

# Status outputs
set_output_delay -clock clk_100mhz -max 5.0 [get_ports timestamp_valid]
set_output_delay -clock clk_100mhz -min 1.0 [get_ports timestamp_valid]

set_output_delay -clock clk_100mhz -max 5.0 [get_ports sync_locked]
set_output_delay -clock clk_100mhz -min 1.0 [get_ports sync_locked]

# Debug outputs (relaxed timing)
set_output_delay -clock clk_100mhz -max 10.0 [get_ports {debug_status[*]}]
set_output_delay -clock clk_100mhz -min 2.0 [get_ports {debug_status[*]}]

# LED outputs (very relaxed timing)
set_output_delay -clock clk_100mhz -max 20.0 [get_ports led_*]
set_output_delay -clock clk_100mhz -min 5.0 [get_ports led_*]

# =============================================================================
# False Paths
# =============================================================================

# Reset is asynchronous
set_false_path -from [get_ports rst_n]

# Cross-domain synchronizers
set_false_path -through [get_pins */sync_reg[0]/D]
set_false_path -through [get_pins */reset_sync_reg[0]/D]

# Debug signals are not timing critical
set_false_path -to [get_ports {debug_status[*]}]

# =============================================================================
# Multicycle Paths
# =============================================================================

# Slow control signals can have relaxed timing
set_multicycle_path -setup 2 -from [get_clocks clk_100mhz] \
    -to [get_pins */calibration_timer_reg[*]/D]
set_multicycle_path -hold 1 -from [get_clocks clk_100mhz] \
    -to [get_pins */calibration_timer_reg[*]/D]

# =============================================================================
# Max Delay Constraints for Critical Paths
# =============================================================================

# PPS generation path must be fast
set_max_delay 5.0 -from [get_pins */current_subseconds_reg[*]/Q] \
              -to [get_pins */pps_pulse_reg/D]

# Timestamp processing path
set_max_delay 50.0 -from [get_pins */timestamp_buffer_reg[*]/Q] \
               -to [get_pins */seconds_since_2000_reg[*]/D]

# =============================================================================
# Clock Domain Crossing Constraints
# =============================================================================

# Constrain synchronizer chains
set_max_delay 10.0 -from [get_clocks t2mi_clk] \
              -to [get_pins */t2mi_data_sync_reg[*]/D] -datapath_only

set_max_delay 10.0 -from [get_clocks t2mi_clk] \
              -to [get_pins */t2mi_valid_sync_reg/D] -datapath_only

# =============================================================================
# Area and Power Constraints
# =============================================================================

# Optimize for timing first, then area
set_max_area 0

# Power optimization for non-critical paths
set_power_opt [get_cells -hierarchical led_*]

# =============================================================================
# Design Rules
# =============================================================================

# Maximum fanout
set_max_fanout 20 [all_outputs]
set_max_fanout 50 [get_nets */clk_100mhz]

# Maximum transition time
set_max_transition 0.5 [all_outputs]
set_max_transition 0.3 [get_ports pps_out]  # Stricter for PPS

# Maximum capacitance
set_max_capacitance 50 [all_outputs]

# =============================================================================
# Exceptions for Specific Modules
# =============================================================================

# Parser state machine can be slower
set_multicycle_path -setup 2 \
    -from [get_pins */parser_inst/parser_state_reg[*]/Q] \
    -to [get_pins */parser_inst/next_state_reg[*]/D]

# Timestamp extractor has relaxed timing except for output
set_multicycle_path -setup 3 \
    -from [get_pins */extractor_inst/byte_index_reg[*]/Q] \
    -through [get_pins */extractor_inst/timestamp_buffer_reg[*]/D]

# =============================================================================
# Report Settings
# =============================================================================

# Report timing paths
report_timing -max_paths 10 -nworst 2 -delay_type max
report_timing -max_paths 10 -nworst 2 -delay_type min

# Report constraint violations
report_constraint -all_violators

# Report clock networks
report_clock_networks

# Report clock domain crossings
report_cdc