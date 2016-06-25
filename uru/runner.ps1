$ToolsPath = 'C:\tools'
$ReportsPath = "${ToolsPath}\reports"
$RubyPath = "${ToolsPath}\ruby"
$GEM_VERSION = '2.1.0'
$RAKE_VERSION = '10.1.0'
$RUBY_VERSION = '2.1.7'


$userprofile = [Environment]::GetFolderPath('UserProfile') 
# [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])
mkdir "${UserProfile}\.uru" -erroraction silentlycontinue
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
"@ |out-file -FilePath "${UserProfile}\.uru\rubies.json" -encoding ASCII
pushd $ToolsPath
$PWD =  pwd | select-object -expandproperty PATH
$env:PATH="${env:PATH};${PWD}"
# write-output $env:PATH
invoke-expression -command 'uru_rt.exe admin add ruby\bin'
$data = invoke-expression -command 'uru_rt.exe ls'
# write-output ("data = '{0}'" -f $data )
# if ( -not $data -match '^\s+\b(\w+)\b.*$') { exit 1}
$tag = ($data -replace '^\s+\b(\w+)\b.*$', '$1')
# write-output ("tag = '{0}'" -f $tag )
$env:URU_INVOKER = 'powershell'
uru_rt.exe $tag
uru_rt.exe ruby "${RubyPath}\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake" spec

popd 

# type "${ReportsPath}\report_.json"

$report = get-content -path "${ReportsPath}\report_.json" |convertfrom-json
write-output ($report.'summary_line')