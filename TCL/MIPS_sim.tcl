quit -sim
.main clear

set PrefMain(saveLines) 10000000

cd C:/daneshgah/fpga/Project_1/sim
cmd /c "if exist work rmdir /S /Q work"
vlib work
vmap work


vcom -2008 ../Source/*.vhd
vcom -2008 ../test/MIPS_tb.vhd

vsim -t 100ps -vopt MIPS_tb
config wave -signalnamewidth 1

add wave -format Logic -radix decimal sim:/MIPS_tb/MIPS_Inst/dataMemory_Inst/ram
add wave -format Logic -radix decimal sim:/MIPS_tb/MIPS_Inst/*
add wave -format Logic -radix decimal sim:/MIPS_tb/MIPS_Inst/controlUnit_Inst/state
add wave -format Logic -radix decimal sim:/MIPS_tb/MIPS_Inst/registerFile_Inst/ram


run -all

# do C:/daneshgah/fpga/Project_1/TCL/MIPS_sim.tcl