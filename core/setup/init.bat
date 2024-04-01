:; sh ./system/unix/unix_setup.sh; exit $?

@echo off
pushd platform\windows
call win_setup
popd

exit /b 0
