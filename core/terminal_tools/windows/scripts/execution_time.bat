@echo off

setlocal

set strt=%1
set endt=%2

REM This code had an issue giving "Unbalanced parenthesis error" - 02/17/24 ~ 09.15
:Calculating_Elapsed_time
set /A elpsd="(1%endt:~0,2%-1%strt:~0,2%)*360000 + (1%endt:~3,2%-1%strt:~3,2%)*6000 + (1%endt:~6,2%-1%strt:~6,2%)*100 + (1%endt:~9,2%-1%strt:~9,2%)"
if %elpsd% LSS 0 set /A elpsd="%elpsd% + 24*360000"

:Display
set /A "cc=elpsd%%100+100,elpsd/=100,ss=elpsd%%60+100,elpsd/=60,mm=elpsd%%60+100,hh=elpsd/60+100"
endlocal & set _executionTime=%hh:~1%:%mm:~1%:%ss:~1%.%cc:~1%
