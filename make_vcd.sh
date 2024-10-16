#!/bin/bash

# Compile the design and testbench
iverilog -g2012 -o rename_record_table_tb rename_table.sv rename_table_tb.sv

# Run the simulation
vvp rename_record_table_tb
