$ToolsPath='C:\tools'
$RubyPath="${ToolsPath}\ruby"

mkdir "${env:USERPROFILE}\.uru" -erroraction silentlycontinue

@"

{
  "Version": "1.0.0",
  "Rubies": {
    "3516592278": {
      "ID": "2.1.8-p440",
      "TagLabel": "218p440",
      "Exe": "ruby",
      "Home": "$($RubyPath -replace '\\', '\\')\\bin",
      "GemHome": "",
      "Description": "ruby 2.1.8p440 (2015-12-16 revision 53160) [i386-mingw32]"

    }
  }
}
"@ |out-file -FilePath "${env:USERPROFILE}\.uru\rubies.json" -encoding ASCII
pushd $ToolsPath

$PWD =  pwd | select-object -expandproperty PATH
$env:PATH="${env:PATH};${PWD}"
# write-output $env:PATH
$data = invoke-expression -command ". .\uru.ps1 ls"
write-output ("data = '{0}'" -f $data )
# $data -match '^\s+\b(\w+)\b.*$'
$tag = ($data -replace '^\s+\b(\w+)\b.*$', '$1')
write-output ("tag = '{0}'" -f $tag )
$env:URU_INVOKER = 'powershell'
uru_rt.exe $tag
uru_rt.exe ruby "${RubyPath}\lib\ruby\gems\2.1.0\gems\rake-11.1.2\bin\rake" spec

popd 
