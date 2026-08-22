# Call this script if you plan to contribute to the repository

set output_dir "./bd"

if {![file exists $output_dir]} {
    file mkdir $output_dir
}

set project_bds [get_files -quiet *.bd]

if {[llength $project_bds] > 0} {
    
    foreach bd_file $project_bds {
        set bd_name [file rootname [file tail $bd_file]]
        open_bd_design $bd_file
        set target_tcl "${output_dir}/${bd_name}.tcl"
        write_bd_tcl -force -no_ip_version $target_tcl
        
    }
} 