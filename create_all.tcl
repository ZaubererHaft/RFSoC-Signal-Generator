set project_name "signal-generator-pl"

# Close open project if necessary
if {[current_project -quiet] != ""} {
    puts "INFO: Schließe offenes Projekt im Speicher..."
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
    ".Xil" \
]

# Delete old files
puts "INFO: Starte Bereinigung des Root-Verzeichnisses..."
foreach item $files_to_clean {
    if {[file exists $item]} {
        puts "INFO: Lösche $item..."
        file delete -force $item
    }
}
puts "INFO: Bereinigung abgeschlossen. Starte Projekt-Neuaufbau..."

# Build project and design files
source create_project.tcl

# find block designs
set bd_file [get_files *.bd]

# generator HDL wrapper on disk
make_wrapper -files $bd_file -top

set wrapper_files [glob -nocomplain ./vivado_project/*.gen/sources_1/bd/*/*_wrapper.[vh]*]

# Add the wrapper files
if {[llength $wrapper_files] > 0} {
    puts "INFO: Wrapper found, add: $wrapper_files"
    add_files -norecurse [file normalize [lindex $wrapper_files 0]]
} else {
    puts "WARNING: Wrappers not found in gen path."
    puts "Please create wrappers manually in the vivado ui (right click -> create HDL wrapper)"
}

# Refresh compil folder
update_compile_order -fileset sources_1

