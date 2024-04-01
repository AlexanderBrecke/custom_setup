@echo off
(for %%a in (%*) do if exist "%%~a" (
    pushd "%%~dpa" && ( copy /b "%%~nxa"+,, & popd )
) else (
    type nul > "%%~fa"
)) >nul 2>&1
