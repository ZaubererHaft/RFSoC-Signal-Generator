# Call this script if you plan to contribute to the repository
set base_output_dir "./bd"

set project_bds [get_files -quiet *.bd]

if {[llength $project_bds] > 0} {
    
    foreach bd_file $project_bds {
        set bd_name [file rootname [file tail $bd_file]]

        set is_in_sim [get_files -quiet -of_objects [get_filesets sim_1] [file tail $bd_file]]
        
        if {[llength $is_in_sim] > 0} {
            set target_fileset "sim_1"
        } else {
            set target_fileset "sources_1"
        }

        set output_dir "${base_output_dir}/${target_fileset}"
        if {![file exists $output_dir]} { 
            file mkdir $output_dir 
        }

        open_bd_design $bd_file
        set target_tcl "${output_dir}/${bd_name}.tcl"
        write_bd_tcl -force -no_ip_version $target_tcl
    }
} 