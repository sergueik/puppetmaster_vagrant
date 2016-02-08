require 'spec_helper'
context 'File version' do
  version = '6.1.7600.16385'
  file_path = ''
  describe command(<<-EOF
$file_path = '#{file_path}'
if ($file_path -eq '') {
 $file_path = "${env:windir\system32\notepad.exe}"
}
$info = get-item -path $file_path
write-output ($info.VersionInfo | convertto-json)
EOF
do 
  its(:output) do
    should match /"ProductVersion":  "#{version}"/
  end 
  end 
end
