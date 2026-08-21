@echo off

if "%~1"=="" (
    echo "Please pass a project name - "
    echo "Example usage: recreate_pl.bat my_project"
    exit /b 1
)
set PROJECT_NAME=%~1

call vivado.bat -mode batch -source recreate_pl.tcl -tclargs %PROJECT_NAME%