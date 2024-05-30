source compile.tcl
vsim work.risv_tb -t 10ps -voptargs=+acc=lprn
add wave -position insertpoint sim:/risv_tb/riscv_i/control_unit_i/*
add wave -position insertpoint sim:/risv_tb/riscv_i/datapath_i/*
add wave -position insertpoint sim:/risv_tb/riscv_i/datapath_i/reg_file/*