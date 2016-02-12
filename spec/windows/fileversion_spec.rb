require_relative '../windows_spec_helper'

context 'File version' do # example of handling the convertto_json format
  {
   'c:\windows\system32\notepad.exe' => '6.1.7600.16385',
   'c:/programdata/chocolatey/choco.exe' =>  '0.9.9.11',
  }.each do |file_path, file_version|
    describe command(<<-EOF
$file_path = '#{file_path}'
if ($file_path -eq '') {
 $file_path = "${env:windir}\\system32\\notepad.exe"
}
try {
  $info = get-item -path $file_path
  write-output ($info.VersionInfo | convertto-json)
} catch [Exception]  { 
  write-output 'Error reading file'
}
EOF
  ) do
      its(:stdout) do

        # x = '(abc)' # => "(abc)"
        # x.gsub(/[abc]/,"\\#{$&}")  # => "(\\a\\a\\a)"
        # x.gsub(/(a|b|c)/,"\\#{$&}") # => "(\\c\\c\\c)"

        should match Regexp.new('"FileName":  "' + file_path.gsub('/','\\').gsub(/\\/,'\\\\\\\\\\\\\\\\').gsub('(','\\(').gsub(')','\\)') + '"', Regexp::IGNORECASE)
        should match /"ProductVersion":  "#{file_version}"/
      end
    end 
    describe file(file_path.gsub('/','\\')) do
      it { should be_version(file_version) }
    end
  end 
end


context 'File version Powershell 2.0' do # Powershell 2.0 lacks convertto-json cmdlet
  {
   'C:\Program Files (x86)\Columbo\Columbo.exe' =>  '1.1.1.0',
  }.each do |file_path, file_version|
    describe command(<<-EOF
    $file_path = '#{file_path}'
      try {
        $info = get-item -path $file_path        
        write-output ($info.VersionInfo | format-list)
      } catch [Exception]  { 
        write-output 'Error reading file'
      }
    EOF
    ) do
        its(:stdout) do
          should match /ProductVersion +: +#{file_version}/
        end
      end 
    end 
  end
