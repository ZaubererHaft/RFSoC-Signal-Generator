set project_name [lindex $argv 0]

# Close open project if necessary
if {[current_project -quiet] != ""} {
    close_project
}

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

# Build project and design files
set ::user_project_name "$project_name"
source recreate_vivado_project.tcl 

# Refresh compile folder
update_compile_order -fileset sources_1

