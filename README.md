# Signal Generator 
This Repository implements a simple signal generator for the ZCU111 RFSoC-Board.

## Project Scripts
Unfortunately, vivado is very inconvenient when it comes to version control systems like git. 

### Setup
To initialize the project, clone this repository and navigate to its root directory. Then open vivado in tcl mode with the command
```
vivado -mode tcl
```
Create the repository with the [create_all.tcl](create_all.tcl) script:
```
Vivado% source create_all.tcl
```
This will build the project using the provided tcl scripts and create the HDL wrappers where required.

### Contribute
If you plan to update to this repository, navigate to the root directory in the vivado tcl console:
```
cd <path>
```
and then invoke the script [export_for_git.tcl](export_for_git.tcl):
```
source export_for_git.tcl
```
which will rewrite the tcl script ([create_project.tcl](create_project.tcl)) creating the project (including block designs)

### Update
To incorporate updates locally, pull all changes via git first. Then you need to fully re-create the vivado project with
```
Vivado% source create_all.tcl
```
similar when initializing the project under [Setup](#Setup).

> [!WARNING]
> Calling the script will delete all existing files - make sure to commit merge your changes before updating

## Architecture
