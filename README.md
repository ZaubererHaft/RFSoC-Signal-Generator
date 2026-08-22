# RFSoc Signal Generator

# Clone, Push and Pull
Working with Vivado and Vitis within a version control system can be cumbersome. The following steps show how to set up the project bor both.

## Clone
After cloning the repository, you need to create Vivado and Vitis projects first. For convenience, you can use the provided script:
```
./create_projects.sh siggen
```
> [!NOTE]
> Executing this command will create the FPGA's bitsream and might take a while

## Pull
If you want to incorporate updates from the repository, pull all changes via git first. Depending on where the changes are, re-create the Vivado project by calling 
```
vivado -mode batch -source create_vivado_project.tcl -tclargs siggen
```
or re-create the Vitis project with
```
vitis -s create_vitis_project.py
```
however note that the latter requires the hardware platform available as xsa file. 

If you just want to include all changes from PS and PL, simply call 
```
./create_projects.sh siggen
```
again - but be aware that the bitstream is generated on this call which takes some time.

> [!WARNING]
> Calling the scripts will delete all old project files - make sure to commit and merge your changes before updating!

## Push
Use the folders `src-pl` and `src-ps` to add new source files (both for HDL and C code). Make sure that you do not copy the files locally to your project, instead reference to the files within the folders (otherwise they won't be commited).

If you plan to update the Vivado project *after* its generation, navigate to the root directory in the Vivado tcl console:
```
cd <path>
```
and then invoke the script [export_vivado_for_git.tcl](export_vivado_for_git.tcl):
```
source export_vivado_for_git.tcl
```
which will re-write tcl-scripts for all block designs. Then add and commit as usual.


## Clean up
Call
```
./cleanup.sh siggen
```
to delete all generated files manually.

## Known Issues
When using Windows, copy this template to a higher level folder like `C:\projects` or similar. If you have a deep nested folder structure, the code generation might be incomplete with the message
```
CMake Warning in libsrc/standalone/src/CMakeLists.txt:
  The object file directory
    ...
  has ... characters.  The maximum full path to an object file is 250
  characters (see CMAKE_OBJECT_PATH_MAX).  Object file
    743a002251c87983b35effde48ecde8c/translation_table.S.obj
  cannot be safely placed under this directory.  The build may not work
  correctly.
```
and compilation won't succeed.

In addition, make sure to validate your block designs - if there are errors, the exported tcl-script might fail generating the project.