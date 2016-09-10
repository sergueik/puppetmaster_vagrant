# uru rake serverspec bootstrap script

$URU_PATH = 'C:\uru'
$RESULTS_PATH = "${URU_PATH}\results"
$RUBY_PATH = "${URU_PATH}\ruby"

$GEM_VERSION = '2.1.0'
$RAKE_VERSION = '10.1.0'
$RUBY_VERSION = '2.1.7'
$RUBY_VERSION_LONG = '2.1.7-p400'

# Under Puppet, the expression $env:USERPFOFILE expression appears to not be set
# so instead of [Environment]::GetFolderPath('UserProfile') use 'Personal'
# http://windowsitpro.com/powershell/easily-finding-special-paths-powershell-scripts
$USERPROFILE = ([Environment]::GetFolderPath('Personal')) -replace '\\Documents', ''

# https://richardspowershellblog.wordpress.com/2008/03/20/special-folders/
# https://msdn.microsoft.com/en-us/library/windows/desktop/bb774096%28v=vs.85%29.aspx
$ssfPROFILE  = 0x28
$USERPROFILE = Get-ChildItem ( (New-Object -ComObject Shell.Application).Namespace($ssfPROFILE).Self.Path)
write-debug "USERPROFILE=${USERPROFILE}"

mkdir "${USERPROFILE}\.uru" -erroraction silentlycontinue
@"

{
  "Version": "1.0.0",
  "Rubies": {
    "3516592278": {
      "ID": "${RUBY_VERSION_LONG}",
      "TagLabel": "$($RUBY_PATH -replace '[\-\.]', '')",
      "Exe": "ruby",
      "Home": "$($RUBY_PATH -replace '\\', '\\')\\bin",
      "GemHome": "",
      "Description":  "ruby $($RUBY_PATH -replace '\-', '') (2015-08-18 revision 51632) [x64-mingw32]"
    }
  }
}
"@ |out-file -FilePath "${USERPROFILE}\.uru\rubies.json" -encoding ASCII

$env:PATH = "${env:PATH};${URU_PATH}"

invoke-expression -command 'uru_rt.exe admin add ruby\bin'

$TAG = (invoke-expression -command 'uru_rt.exe ls') -replace '^\s+\b(\w+)\b.*$', '$1'
write-debug ("tag = '{0}'" -f $TAG )

# bootstrap Rspec
$env:URU_INVOKER = 'powershell'

uru_rt.exe $TAG
uru_rt.exe ruby "${RUBY_PATH}\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake" spec

popd

# extract summary_line
# NOTE: convertFrom-json requires Powershell 3.
$report = get-content -path "${RESULTS_PATH}\result.json" | convertfrom-json
write-output ($report.'summary_line')