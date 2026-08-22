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
# Add all hdl sources to source_1
if {[llength [glob -nocomplain $project_dir/src-pl/*.vhd $project_dir/src-pl/*.v $project_dir/src-pl/*.sv]] > 0} {
    add_files [glob $project_dir/src-pl*]
}

# Add all hdl sources to sim_1
if {[llength [glob -nocomplain $project_dir/src-sim/*.vhd $project_dir/src-sim/*.v $project_dir/src-sim/*.sv]] > 0} {
    add_files -fileset sim_1 [glob $project_dir/src-sim*]
}

# Add constraints file
if {[llength [glob -nocomplain $project_dir/constraints/*.xdc]] > 0} {
    add_files -fileset constrs_1 [glob ./constraints/*.xdc]
}

# ==============================================================================
# 4. Create block designs (Ugly!)
# ==============================================================================
set is_new_project 1

# Re-Create: There are already designs
foreach fileset {"sources_1" "sim_1"} {
    set bd_tcl_files [glob -nocomplain "${project_dir}/bd/${fileset}/*.tcl"]

    if {[llength $bd_tcl_files] > 0} {
        foreach tcl_file $bd_tcl_files {
            # Which BD in which fileset?
            set bd_name [file rootname [file tail $tcl_file]]

            # Create BD (easy)
            source $tcl_file

            # Now super ugly: move the created block design to the correct file set (it is always created in sources_1, NO chance to change this)
            if {$fileset != "sources_1"} {
                set src_bd_dir "${project_dir}/${project_name}.srcs/sources_1/bd/${bd_name}"
                set dest_bd_dir "${project_dir}/${project_name}.srcs/${fileset}/bd/${bd_name}"
                set final_bd_file "${dest_bd_dir}/${bd_name}.bd"

                current_fileset $fileset
                remove_files -fileset sources_1 [get_files ${bd_name}.bd]

                set dest_parent_dir "${project_dir}/${project_name}.srcs/${fileset}/bd"
                if {![file exists $dest_parent_dir]} {
                    file mkdir $dest_parent_dir
                }

                if {[file exists $src_bd_dir]} {
                    file rename -force $src_bd_dir $dest_bd_dir
                }

                add_files -fileset $fileset $final_bd_file

            } else {
                current_fileset
            }

            # create block design (still okay)
            open_bd_design [get_files ${bd_name}.bd]
            validate_bd_design
            save_bd_design

            # create wrapper ...
            set bd_file [get_files ${bd_name}.bd]
            make_wrapper -fileset $fileset  -files $bd_file -top 

            # .. wait for it ...
            set src_gen_dir  "${project_dir}/${project_name}.gen/sources_1/bd/${bd_name}"
            set dest_gen_dir "${project_dir}/${project_name}.gen/${fileset}/bd/${bd_name}"
            set src_wrapper_dir  "${project_dir}/${project_name}.gen/sources_1/bd/${bd_name}/hdl"
            set dest_wrapper_dir "${project_dir}/${project_name}.gen/${fileset}/bd/${bd_name}/hdl"
            set src_wrapper_file  "${src_wrapper_dir}/${bd_name}_wrapper.v"
            set dest_wrapper_file "${dest_wrapper_dir}/${bd_name}_wrapper.v"

            #... again SUPER ugly, move the wrapper too, make_wrapper constantly ignores the fileset argument
            if {$fileset != "sources_1"} {
                if {[llength [get_files -quiet "${bd_name}_wrapper.v"]] > 0} {
                    remove_files -fileset sources_1 [get_files "${bd_name}_wrapper.v"]
                }

                set dest_gen_parent "${project_dir}/${project_name}.gen/${fileset}/bd"
                if {![file exists $dest_gen_parent]} {
                    file mkdir $dest_gen_parent
                }

                if {[file exists $src_gen_dir] && ![file exists $dest_gen_dir]} {
                    puts "Verschiebe den gesamten Generierungs-Ordner physisch nach ${fileset}..."
                    file rename -force $src_gen_dir $dest_gen_dir
                }
                
                add_files -fileset $fileset -norecurse $dest_wrapper_file
            } else {
                add_files -fileset sources_1 -norecurse $src_wrapper_file
            }

        }
        set is_new_project 0
    } 

} 

if {$is_new_project > 0} {
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

