@echo off

setlocal

set algorithm=%1
if "%algorithm%" == "" GOTO :NOALGORITHM

set /p path_to_file=Enter path to file: 
set /p check_sum=Enter check sum: 
REM Make sure check sum is upper case
for /f "delims=" %%a in ('powershell "\"%check_sum%\".toUpper()"') do set "check_sum=%%a"

REM Get hash of the file
for /f "delims=" %%a in ('powershell -Command "(Get-FileHash -Path %path_to_file% -Algorithm %algorithm%).Hash"') do set "file_hash=%%a"

echo "File hash: %file_hash%"

echo ---

if %file_hash% == %check_sum% goto :CORRECTHASH
echo Hash does not match
exit /b

:CORRECTHASH
echo Hash matches
exit /b

:NOALGORITHM
Echo No algorithm was input, please give algorithm with command: "check_filesum <algorithm>"
exit /b
