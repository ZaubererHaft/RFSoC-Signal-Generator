set project_name [lindex $argv 0]

open_project $project_name.xpr
launch_runs impl_1 -to_step write_bitstream -jobs 24
wait_on_run impl_1
write_hw_platform -fixed -include_bit -force -file ./main_wrapper.xsa