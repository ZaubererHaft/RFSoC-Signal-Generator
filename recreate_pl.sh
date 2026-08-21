#!/bin/bash

if [ -z "$1" ]; then
    echo "Please pass a project name - "
    echo "Example usage: ./recreate_pl.sh my_project"
    exit 1
fi

PROJECT_NAME="$1"

vivado -mode batch -source recreate_pl.tcl -tclargs "$PROJECT_NAME"