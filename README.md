# RFSoc Signal Generator

# Clone, Push and Pull

## Clone
After cloning the repository, you need to create a vivado project first. For convenience, you can use the provided scripts:
```
./create_projects.sh <project-name>
```
where `project-name` can be chosen arbitrarily.
This cript creates a simple Vivado project for the PL and a Vitis project for the PS with the given name and the following content:

* In Vivado, a block design called `main` is created with an empty but pre-routed MPCSoC IP block.
* In addition, the default constraints file as well as a test Verilog file is added to the project. 
* Then, the bitstream for the project is generated and the hardware XSA is exported for the PS project.
* The PS project is generated within the workspace `vitis-ws`. 
* A default platform as well as a sample project including a main function is added.

You can use this script as a template for own projects.  In this case, overwrite the template project as described in the [Pull](#Pull) section.

## Pull
After project creation (e.g., because you first cloned to project) or if you want to incorporate updates from the repository, pull all changes via git first. Then re-create the Vivado project with
```
./recreate_pl.sh <project-name>
```

The Vitis project should be re-created with the script
```
vitis -s create_vitis_project.py
```

> [!WARNING]
> Calling the scripts will delete all project files - make sure to commit and merge your changes before updating!

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
which will write a tcl-script called `recreate_vivado_project.tcl` re-creating the project (including block designs). Then add and commit as usual.


## Clean up
Call
```
./cleanup.sh <project-name>
```
to delete all generated files

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