# TODO: assert where.exe puppet.bat
$PuppetInstallDir = invoke-expression -command 'facter.bat env_windows_installdir'
write-output $PuppetInstallDir
$RubyPath = "${PuppetInstallDir}\sys\ruby"
write-output $RubyPath

$env:PATH = "${env:PATH};${RubyPath}\bin"

$GEM_VERSION = '2.1.0'
$RAKE_VERSION = '10.1.0'
$RUBY_VERSION = '2.1.7'
pushd c:\uru
invoke-expression -command "ruby `"${RubyPath}\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake`" spec"
