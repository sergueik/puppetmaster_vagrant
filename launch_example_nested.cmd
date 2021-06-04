@echo OFF
REM this adds a custom direcory to the PATH and runs the command from that directory
REM example git configuraion command that creates a dot file in user directory
REM for sake of illustration  use chromedriever command
REM NOTE: saving in csv format willcorrupt the command
powershell.exe -noprofile -executionpolicy remotesigned "&{$env:PATH=('{0};{1}' -f $env:PATH, 'c:\java\selenium'); invoke-expression 'chromedriver.exe -v' | out-null }"
REM NOTE  command easily becomes too long and silently fails
powershell.exe -noprofile -executionpolicy remotesigned "&{ param( $d = 10 ) $env:PATH=($env:PATH +';' + 'c:\java\selenium'); [array]$r = iex 'chromedriver.exe -v' ;write-host $r[0]; start-sleep $d; }" 10

powershell.exe -noprofile -executionpolicy remotesigned "&{ $env:PATH=('{0};{1}' -f $env:PATH, 'c:\java\selenium'); $result = invoke-expression 'chromedriver.exe -v' ;write-host $result; start-sleep 10; }"

REM deal with arguments.
REM Note: no need in "argumentlist" when invoked from cmd
powershell.exe -noprofile -executionpolicy remotesigned "& { write-output $args ; } " -argumentlist "a,b,c"
REM will print the following
REM -argumentlist
REM a
REM b
REM c

