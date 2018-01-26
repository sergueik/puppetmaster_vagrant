@rem  Embedded Ruby polyglot script
@echo OFF
REM a long version
REM for one-liner see
REM origin: https://github.com/gregzakh/cmdiffusion/blob/master/tests/ruby.cmd
SETLOCAL
ruby --version 2> NUL 1> NUL
if %ERRORLEVEL% == 9009 set PATH=%PATH%;c:\program files\puppet labs\puppet\sys\ruby\bin
ruby -x "%~f0" %* 
ENDLOCAL
exit /b 0
#!/usr/bin/env ruby
puts "Testing ruby...#{ARGV.join(' ')}"
