set project_name [lindex $argv 0]
set project_dir .
set fpga "xczu28dr-ffvg1517-2-e"
set board "xilinx.com:zcu111:part0:1.4"

# Create project
create_project $project_name $project_dir -part $fpga
set_property board_part $board [current_project]

# Create main block design
create_bd_design "main"
update_compile_order -fileset sources_1
make_wrapper -files [get_files $project_dir/$project_name.srcs/sources_1/bd/main/main.bd] -top
add_files -norecurse $project_dir/$project_name.gen/sources_1/bd/main/hdl/main_wrapper.v

# create MPSoc
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
save_bd_design

# Add constraints file
add_files -fileset constrs_1 -norecurse constraints/ZCU111_Rev1.0.xdc

# Add sample verilog file
add_files -norecurse C:/rfsoc-examples/tmp/src-pl/pwm.v