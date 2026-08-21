@echo off

if "%~1"=="" (
    echo "Please pass a project name - "
    echo "Example usage: create_projects.bat my_project"
    exit /b 1
)

set PROJECT_NAME=%~1

call vivado.bat -mode batch -source create_vivado_project.tcl -tclargs %PROJECT_NAME%
call vivado.bat -mode batch -source create_bitsream_and_xsa.tcl -tclargs %PROJECT_NAME%
call vitis.bat -s create_vitis_project.py