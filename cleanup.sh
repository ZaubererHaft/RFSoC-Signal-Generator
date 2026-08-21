#!/bin/bash

if [ -z "$1" ]; then
    echo "Please pass a project name - "
    echo "Example usage: ./cleanup.sh my_project"
    exit 1
fi

PROJECT_NAME="$1"

rm -rf "${PROJECT_NAME}.cache"
rm -rf "${PROJECT_NAME}.gen"
rm -rf "${PROJECT_NAME}.hw"
rm -rf "${PROJECT_NAME}.ip_user_files"
rm -rf "${PROJECT_NAME}.runs"
rm -rf "${PROJECT_NAME}.srcs"
rm -rf "${PROJECT_NAME}.sim"

rm -rf .Xil
rm -rf vitis-ws

rm -f *.jou *.log *.xsa *.xpr *.txt