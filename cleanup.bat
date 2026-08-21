@echo off

if "%~1"=="" (
    echo "Please pass a project name - "
    echo "Example usage: cleanup.bat my_project"
    exit /b 1
)
set PROJECT_NAME=%~1

rmdir /s /q %PROJECT_NAME%.cache
rmdir /s /q %PROJECT_NAME%.gen
rmdir /s /q %PROJECT_NAME%.hw
rmdir /s /q %PROJECT_NAME%.ip_user_files
rmdir /s /q %PROJECT_NAME%.runs
rmdir /s /q %PROJECT_NAME%.srcs
rmdir /s /q %PROJECT_NAME%.sim

rmdir /s /q .Xil
rmdir /s /q vitis-ws

del /f /q *.jou
del /f /q *.log
del /f /q *.xsa
del /f /q *.xpr
del /f /q *.txt