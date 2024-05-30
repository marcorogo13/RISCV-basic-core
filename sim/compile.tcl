
rm -r work
vlib work

# Control Unit
vcom -work work ../sources/mypackage.vhd
vcom -work work ../sources/Control_unit/HW_CU.vhd

# Data Path
## ALU
### Adder
vcom -2008 -work work ../sources/datapath/Alu/Adder_P4/full_adder.vhd 
vcom -2008 -work work ../sources/datapath/Alu/Adder_P4/p_g.vhd 
vcom -2008 -work work ../sources/datapath/Alu/Adder_P4/G.vhd  
vcom -2008 -work work ../sources/datapath/Alu/Adder_P4/PG.vhd  
vcom -2008 -work work ../sources/datapath/Alu/Adder_P4/mux21_generic.vhd  
vcom -2008 -work work ../sources/datapath/Alu/Adder_P4/Carry_LookAhead.vhd  
vcom -2008 -work work ../sources/datapath/Alu/Adder_P4/rca_generic.vhd  
vcom -2008 -work work ../sources/datapath/Alu/Adder_P4/carry_select_block.vhd  
vcom -2008 -work work ../sources/datapath/Alu/Adder_P4/sum_generator.vhd  
vcom -2008 -work work ../sources/datapath/Alu/Adder_P4/p4_adder.vhd  

vcom -2008 -work work ../sources/datapath/Alu/alu.vhd  

## Register File
vcom -2008 -work work ../sources/datapath/Register_file/registerfile.vhd  

## Other components 
vcom -2008 -work work ../sources/datapath/generic_mux.vhd  
vcom -2008 -work work ../sources/datapath/Single_bit_register.vhd
vcom -2008 -work work ../sources/datapath/type_register.vhd  
vcom -2008 -work work ../sources/datapath/generic_Register.vhd  
vcom -2008 -work work ../sources/datapath/forward_mux.vhd  
vcom -2008 -work work ../sources/datapath/address_adder.vhd  
vcom -2008 -work work ../sources/datapath/immediate_unit.vhd
vcom -2008 -work work ../sources/datapath/PCIncrementer.vhd

vcom -2008 -work work ../sources/datapath/datapath.vhd  

vcom -2008 -work work ../sources/conv_inst.vhd
vcom -2008 -work work ../sources/fetch_unit.vhd
vcom -2008 -work work ../sources/hazard_forward_unit.vhd
vcom -2008 -work work ../sources/forward_mem_unit.vhd
vcom -2008 -work work ../sources/mem_unit.vhd

#vlog -work work ../sources/riscv.v
vcom -2008 -work work ../sources/riscv.vhd

vcom -2008 -work work ../testbench/instr_ram.vhd
vcom -2008 -work work ../testbench/data_ram.vhd
vcom -2008 -work work ../testbench/riscv_tb.vhd


