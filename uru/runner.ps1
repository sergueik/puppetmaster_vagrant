$ToolsPath = 'C:\tools'
$ReportsPath = "${ToolsPath}\reports"
$RubyPath = "${ToolsPath}\ruby"
$GEM_VERSION = '2.1.0'
$RAKE_VERSION = '10.1.0'
$RUBY_VERSION = '2.1.7'


mkdir "${env:USERPROFILE}\.uru" -erroraction silentlycontinue
# http://annaken.blogspot.com/2015/07/automated-serverspec-logstash-kibana-part2.html
@"

{
  "Version": "1.0.0",
  "Rubies": {
    "3516592278": {
      "ID": "2.1.7-p400",
      "TagLabel": "217p400",
      "Exe": "ruby",
      "Home": "$($RubyPath -replace '\\', '\\')\\bin",
      "GemHome": "",
      "Description":  "ruby 2.1.7p400 (2015-08-18 revision 51632) [x64-mingw32]"
    }
  }
}
"@ |out-file -FilePath "${env:USERPROFILE}\.uru\rubies.json" -encoding ASCII
pushd $ToolsPath
$PWD =  pwd | select-object -expandproperty PATH
$env:PATH="${env:PATH};${PWD}"
# write-output $env:PATH
$data = invoke-expression -command "uru_rt.exe ls"
write-output ("data = '{0}'" -f $data )
# $data -match '^\s+\b(\w+)\b.*$'
$tag = ($data -replace '^\s+\b(\w+)\b.*$', '$1')
write-output ("tag = '{0}'" -f $tag )
$env:URU_INVOKER = 'powershell'
uru_rt.exe $tag
uru_rt.exe ruby "${RubyPath}\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake" spec

popd 
type "${ReportsPath}\\report_.json"
