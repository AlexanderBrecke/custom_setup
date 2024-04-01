@echo off

if [%1]==[] goto :PRINTSCRIPTS

:PRINTSCRIPTS
echo These are the scripts available to you:
echo ...
for /f "usebackq delims=|" %%f in (`dir /b "%~pd0"`) do echo %%f
echo ...

:EXIT
exit /b
