#!/bin/bash

if [ -z "$1" ]; then
    echo "Please pass a project name - "
    echo "Example usage: ./create_projects.sh my_project"
    exit 1
fi

PROJECT_NAME="$1"

vivado -mode batch -source create_vivado_project.tcl -tclargs "$PROJECT_NAME"
vivado -mode batch -source create_bitsream_and_xsa.tcl -tclargs "$PROJECT_NAME"
vitis -s create_vitis_project.py