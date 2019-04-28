@echo off

REM origin: https://habr.com/ru/post/449820/

set XNVIEW=C:\Program Files (x86)\XnView\xnview.exe
set SUBLIME=C:\Program Files\Sublime Text 3\sublime_text.exe
set FOOBAR=C:\Program Files (x86)\foobar2000\foobar2000.exe
set VLC=C:\Program Files (x86)\VideoLAN\VLC\vlc.exe

REM call :assoc_ext "%SUBLIME%" txt md js json css java sh yaml
REM call :assoc_ext "%XNVIEW%" png gif jpg jpeg tiff bmp ico
REM call :assoc_ext "%FOOBAR%" flac fla ape wav mp3 wma m4a ogg ac3
call :assoc_ext "%VLC%" mkv avi ape

goto :eof

:assoc_ext
  set EXE=%1
  shift
  :loop
  if "%1" neq "" (
    ftype my_file_%1=%EXE% "%%1"
    assoc .%1=my_file_%1
    shift
    goto :loop
  )
goto :EOF

REM Displays or modifies file types used in file extension associations
REM 
REM FTYPE [fileType[=[openCommandString]]]
REM 
REM   fileType  Specifies the file type to examine or change
REM   openCommandString Specifies the open command to use when launching files
REM                     of this type.

REM Displays or modifies file extension associations
REM 
REM ASSOC [.ext[=[fileType]]]
REM 
REM   .ext      Specifies the file extension to associate the file type with
REM   fileType  Specifies the file type to associate with the file extension
REM
REM Type ASSOC without parameters to display the current file associations.
REM If ASSOC is invoked with just a file extension, it displays the current
REM file association for that file extension.  Specify nothing for the file
REM type and the command will delete the association for the file extension.
REM 
REM #!/bin/bash
REM 
REM # this allows us terminate the whole process from within a function
REM trap "exit 1" TERM
REM export TERM_PID=$$
REM 
REM # check `duti` installed
REM command -v duti >/dev/null 2>&1 || \
REM   { echo >&2 "duti required: brew install duti"; exit 1; }
REM 
REM get_bundle_id() {
REM     osascript -e "id of app \"${1}\"" || kill -s TERM $TERM_PID;
REM }
REM 
REM assoc() {
REM     bundle_id=$1; shift
REM     role=$1; shift
REM     while [ -n "$1" ]; do
REM         echo "setting file assoc: $bundle_id .$1 $role"
REM         duti -s "$bundle_id" ".${1}" "$role"
REM         shift
REM     done
REM }
REM 
REM SUBLIME=$(get_bundle_id "Sublime Text")
REM TEXT_EDIT=$(get_bundle_id "TextEdit")
REM MPLAYERX=$(get_bundle_id "MPlayerX")
REM 
REM assoc "$SUBLIME" "editor" txt md js jse json reg bat ps1 cfg sh bash yaml
REM assoc "$MPLAYERX" "viewer" mkv mp4 avi mov webm
REM assoc "$MPLAYERX" "viewer" flac fla ape wav mp3 wma m4a ogg ac3
REM 
