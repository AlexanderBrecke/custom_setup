@echo off

setLocal EnableDelayedExpansion

set toCheck=%1
set toLookFor=%2

if not "x!toCheck:%toLookFor%=!"=="x%toCheck%" goto :CONTAINS

endlocal & set "_contains=false"
exit /b 0

:CONTAINS
endlocal & set "_contains=true"
exit /b 0
