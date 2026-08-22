set project_name [lindex $argv 0]
set project_dir .
set fpga "xczu28dr-ffvg1517-2-e"
set board "xilinx.com:zcu111:part0:1.4"

# ==============================================================================
# 1. Clean up
# ==============================================================================
# Close open project if necessary
if {[current_project -quiet] != ""} {
    close_project
}

# Clean up old project
set files_to_clean [list \
    "${project_name}.xpr" \
    "${project_name}.srcs" \
    "${project_name}.gen" \
    "${project_name}.cache" \
    "${project_name}.hw" \
    "${project_name}.ip_user_files" \
    "${project_name}.sim" \
    "${project_name}.runs" \
    ".Xil" \
]

# Delete old files
foreach item $files_to_clean {
    if {[file exists $item]} {
        file delete -force $item
    }
}

# ==============================================================================
# 2. Create project
# ==============================================================================
create_project $project_name $project_dir -part $fpga
set_property board_part $board [current_project]


# ==============================================================================
# 3. Add sources
# ==============================================================================
# Add all hdl sources
if {[llength [glob -nocomplain $project_dir/src-pl/*.vhd $project_dir/src-pl/*.v $project_dir/src-pl/*.sv]] > 0} {
    add_files [glob $project_dir/src-pl*]
}

# Add constraints file
if {[llength [glob -nocomplain $project_dir/constraints/*.xdc]] > 0} {
    add_files -fileset constrs_1 [glob ./constraints/*.xdc]
}

# ==============================================================================
# 4. Create block designs
# ==============================================================================
set bd_tcl_files [glob -nocomplain "${project_dir}/bd/*.tcl"]

# Re-Create: There are already designs
if {[llength $bd_tcl_files] > 0} {

    puts "INFO: Found block designs, re-create them..."
    
    foreach tcl_file $bd_tcl_files {
        set bd_name [file rootname [file tail $tcl_file]]
        source $tcl_file
        
        open_bd_design [get_files ${bd_name}.bd]
        validate_bd_design
        save_bd_design
        
        set bd_file [get_files ${bd_name}.bd]
        
        make_wrapper -files $bd_file -top
        
        set wrapper_path "${project_dir}/${project_name}.srcs/sources_1/bd/${bd_name}/hdl/${bd_name}_wrapper.v"
        if {[file exists $wrapper_path]} {
            add_files -norecurse $wrapper_path
        } else {
            set wrapper_path "${project_dir}/${project_name}.gen/sources_1/bd/${bd_name}/hdl/${bd_name}_wrapper.v"
            add_files -norecurse $wrapper_path
        }
    }
    update_compile_order -fileset sources_1
} else {
    # New repository: create sample block design
    puts "INFO: Initial setup, creating sample block design..."
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
}

