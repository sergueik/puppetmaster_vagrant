@echo Off
rem origin: http://forum.oszone.net/thread-349208.html
rem origin: http://forum.oszone.net/thread-186889.html
rem ussage call :FromDate %DeltaDay% %Date% "MyDate"
rem echo %MyDate%

:FromDate
setLocal
	set "DT=%~2"
	set yyyy=%DT:~-4%& set /a mm=100%DT:~3,2%%%100& set /a dd=100%DT:~,2%%%100
	set /A JD=%~1+dd-32075+1461*(yyyy+4800+(mm-14)/12)/4+367*(mm-2-(mm-14)/12*12)/12-3*((yyyy+4900+(mm-14)/12)/100)/4
	set /A L=JD+68569,N=4*L/146097,L=L-(146097*N+3)/4,I=4000*(L+1)/1461001
	set /A L=L-1461*I/4+31,J=80*L/2447,K=L-2447*J/80,L=J/11
	set /A J=J+2-12*L,I=100*(N-49)+I+L
	set /A yyyy=I,mm=100+J,dd=100+K
endlocal& set "%~3=%dd:~-2%.%mm:~-2%.%yyyy%"
goto :EOF
