@echo off

echo --- Setting up ---
set startTime=%time: =0%

REM check if path contains script folder
:CHECKPATH
setlocal enableDelayedExpansion
set path_to_scripts=%~pd0scripts
if "x!PATH:%path_to_scripts%=!" == "x%PATH%" goto :ADDSCRIPTS
goto :CHECKWDRIVE

REM Add scripts folder to path
:ADDSCRIPTS
endlocal
echo ...
pushd %~pd0cmd_setups
call cmd_setup_add_scripts %~pd0scripts
popd


:CHECKWDRIVE
endlocal
if exist w: goto :EXIT
if exist %USERPROFILE%\work\ goto :ADDWDRIVE

REM Creates a work folder in your user profile if it does not exist
:CREATEWORKFOLDER
echo Work folder not found, creating one at: "%USERPROFILE%\work"
mkdir %USERPROFILE%\work

:ADDWDRIVE
echo ...
pushd %~pd0cmd_setups
call cmd_setup_w_drive %USERPROFILE%\work
popd

:EXIT
echo ...
set endTime=%time: =0%
call execution_time %startTime% %endTime%
echo Setup took %_executionTime%
echo --- Setup finished ---
exit /b
