# uru rake serverspec bootstrap script

$ToolsPath = 'C:\uru'
$ResultsPath = "${ToolsPath}\results"
$RubyPath = "${ToolsPath}\ruby"

$GEM_VERSION = '2.1.0'
$RAKE_VERSION = '10.1.0'
$RUBY_VERSION = '2.1.7'

# when run by Puppet, the user profile environment appears to not be defined
$userprofile = ([Environment]::GetFolderPath('Personal')) -replace '\\Documents', '' 
write-debug "userprofile=${userprofile}"

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
$PWD =  pwd | select-object -expandproperty PATH
$env:PATH = "${env:PATH};${ToolsPath}"
invoke-expression -command 'uru_rt.exe admin add ruby\bin'

$tag = (invoke-expression -command 'uru_rt.exe ls') -replace '^\s+\b(\w+)\b.*$', '$1'
write-debug ("tag = '{0}'" -f $tag )

# bootstrap Ruby

$env:URU_INVOKER = 'powershell'
uru_rt.exe $tag
uru_rt.exe ruby "${RubyPath}\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake" spec

popd 

# type "${ResultsPath}\result.json"
# extract summary_line
# $report = get-content -path "${ResultsPath}\result.json"; $summary_line = $report -replace '.+\"summary_line\"', 'serverspec result: '; write-output $summary_line;

# convertFrom-json requires Powershell 3.
$report = get-content -path "${ResultsPath}\result.json" | convertfrom-json
write-output ($report.'summary_line')
