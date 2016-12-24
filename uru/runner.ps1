$env:URU_INVOKER = 'powershell'
# $URU_HOME='<%= @uru_home -%>'

if ($URU_HOME -eq '') {
  $URU_HOME = 'C:\uru'
}

$env:PATH = "${env:PATH};${URU_HOME}"

$GEM_VERSION = '2.1.0'
$RAKE_VERSION = '10.1.0'
$RUBY_VERSION = '2.1.7'
$RUBY_VERSION_LONG = '2.1.7-p400'
$RUBY_TAG_LABEL = $RUBY_VERSION_LONG -replace '[\-\.]', ''
$URU_RUNNER = "${URU_HOME}\uru_rt.exe"

$USERPROFILE = $HOME
# Cannot overwrite variable HOME because it is read-only or constant.
if ($USERPROFILE -eq '') {
  # Under Puppet, the expression $env:USERPFOFILE expression appears to not be set
  # so instead of [Environment]::GetFolderPath('UserProfile') use 'Personal'
  # http://windowsitpro.com/powershell/easily-finding-special-paths-powershell-scripts
  $USERPROFILE = ([Environment]::GetFolderPath('Personal')) -replace '\\Documents', ''
  # https://richardspowershellblog.wordpress.com/2008/03/20/special-folders/
  # https://msdn.microsoft.com/en-us/library/windows/desktop/bb774096%28v=vs.85%29.aspx
  $ssfPROFILE = 0x28
  $USERPROFILE = (New-Object -ComObject Shell.Application).Namespace($ssfPROFILE).Self.Path
  write-debug "USERPROFILE='${USERPROFILE}'"
}
if (-not (test-path "${USERPROFILE}\.uru")) {
  mkdir "${USERPROFILE}\.uru" -erroraction silentlycontinue
}

@"
{
  "Version": "1.0.0",
  "Rubies": {
    "3516592278": {
      "ID": "${RUBY_VERSION_LONG}",
      "TagLabel": "${RUBY_TAG_LABEL}",
      "Exe": "ruby",
      "Home": "$("${URU_HOME}\ruby\bin" -replace '\\', '\\')",
      "GemHome": "",
      "Description": "ruby $RUBY_VERSION_LONG (2015-08-18 revision 51632) [x64-mingw32]"
    }
  }
}
"@ |out-file -FilePath "${USERPROFILE}\.uru\rubies.json" -encoding ASCII

$TAG = (invoke-expression -command "${URU_RUNNER} ls" -erroraction silentlycontinue) -replace '^\s+\b(\w+)\b.*$', '$1'

if ($TAG -ne '') {
  write-debug ("tag = '{0}'" -f $TAG )
  invoke-expression -command "echo Y| ${URU_RUNNER} admin rm ${TAG}" | out-null
}

invoke-expression -command "${URU_RUNNER} admin add ruby\bin"

if ([bool]$PSBoundParameters['DEBUG'].IsPresent) {
  invoke-expression -command "${URU_RUNNER} ls --verbose"
  invoke-expression -command "${URU_RUNNER} gem list --local"
}

# Run the serverspec
invoke-expression -command "${URU_RUNNER} ruby ""ruby\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake"" spec"

popd

# extract summary_line
# NOTE: convertFrom-json requires Powershell 3.
$RESULTS_PATH = "${URU_HOME}\results"
$report = get-content -path "${RESULTS_PATH}\result.json" | convertfrom-json
write-output ($report.'summary_line')
