require_relative '../windows_spec_helper'

context 'File version' do # example of handling the convertto_json format
  # based on:  http://forum.oszone.net/thread-336138.html (* russian)
  {
   'c:\windows\system32\notepad.exe'                           => '6.1.7600.16385',
   'c:/Program Files/Puppet Labs/Puppet/sys/ruby/bin/ruby.exe' => '2.1.9.490',
   # 'c:/programdata/chocolatey/choco.exe'                     => '0.9.9.11',
  }.each do |file_path, file_version|
    file_path = file_path.gsub(/\\/,'\\\\\\\\')
    file_path = file_path.gsub(/\//,'\\\\\\\\')
    $stderr.puts file_path
    describe command(<<-EOF
      wmic.exe datafile "#{file_path}" get Version /format:list
    EOF
    ) do
      its(:stdout) do
        should match /Version=#{file_version}/
      end
    end
  end
  {
   'c:\windows\system32\notepad.exe'                           => '6.1.7600.16385',
   'c:/Program Files/Puppet Labs/Puppet/sys/ruby/bin/ruby.exe' => '2.1.9p490',
   # 'c:/programdata/chocolatey/choco.exe'                     => '0.9.9.11',
  }.each do |file_path, file_version|
    describe command(<<-EOF
      $file_path = '#{file_path}'
      if ($file_path -eq '') {
       $file_path = "${env:windir}\\system32\\notepad.exe"
      }
      try {
        # a long version of the command
        # (Get-Item $file_path).VersionInfo.FileVersion
        $info = get-item -path $file_path
        write-output ($info.VersionInfo | convertto-json)
      } catch [Exception] {
        write-output 'Error reading file'
      }
    EOF
    ) do
      its(:stdout) do
        # NOTE:
        # x = '(abc)' # => "(abc)"
        # x.gsub(/[abc]/,"\\#{$&}")  # => "(\\a\\a\\a)"
        # x.gsub(/(a|b|c)/,"\\#{$&}") # => "(\\c\\c\\c)"
        should match Regexp.new('"FileName":\\s+"' + file_path.gsub('/','\\').gsub(/\\/,'\\\\\\\\\\\\\\\\').gsub('(','\\(').gsub(')','\\)') + '"', Regexp::IGNORECASE)
        should match /"ProductVersion":  "#{file_version}"/
      end
    end
    describe command(<<-EOF
      $file_path = '#{file_path}'
      if ($file_path -eq '') {
       $file_path = "${env:windir}\\system32\\notepad.exe"
      }
      try {
        $o = ([System.IO.FileInfo]$file_path).VersionInfo
        write-output $o.FileVersion, $o.ProductVersion
      } catch [Exception] {
        write-output 'Error reading file'
      }
    EOF
    ) do
      its(:stdout) do
        should match file_version
      end
    end
    describe file(file_path.gsub('/','\\')) do
      it { should be_version(file_version) }
    end
  end
end


context 'File version Powershell 2.0' do # Powershell 2.0 lacks convertto-json cmdlet
  {
   # 'C:\Program Files (x86)\Columbo\Columbo.exe'                => '1.1.1.0',
   'c:\Program Files\Puppet Labs\Puppet\sys\ruby\bin\ruby.exe' => '2.1.9p490',
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