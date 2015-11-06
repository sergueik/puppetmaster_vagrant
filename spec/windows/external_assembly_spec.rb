require_relative '../windows_spec_helper'
context 'externl assembly' do
 context 'Download and execute .net assembly for testing of the system' do
    assembly_url =  'http://github.com/nunit/nunitv2/releases/download/2.6.4/NUnit-2.6.4.zip' 
    zip_download_path =  'c:/temp' 
    zip_filename =  'nunit.zip' 
    dll_name = 'nunit.framework.dll'
    describe command(<<-END_COMMAND
$dll_name = '#{dll_name}'
$zip_download_path="#{zip_download_path}"
$assembly_url = '#{assembly_url}'
$zip_filename = '#{zip_filename}'
$zip_fullname = "${zip_download_path}/${zip_filename}"
write-output ('Download "{0}" to "{1}"' -f $assembly_url, $zip_fullname)
(new-object -typename 'System.Net.WebClient').DownloadFile($assembly_url,$zip_fullname)

write-output 'Check the file is present'
test-path -LiteralPath $zip_fullname -ErrorAction Stop
write-output 'extract the file'
[string]$extract_path = ('{0}\\Desktop\\Extract' -f $env:USERPROFILE)
[System.IO.Directory]::CreateDirectory($extract_path)
$o = New-Object -COM 'Shell.Application'
$o.namespace((Convert-Path $extract_path)).Copyhere($o.namespace((Convert-Path $zip_fullname)).items(), 16)

write-output ('Load assembly' -f $dll_name)
add-type -path ('{0}\\NUnit-2.6.4\\bin\\{1}' -f $extract_path, $dll_name)
write-output 'Throw sample assertion exception'
[NUnit.Framework.Assert]::IsTrue($true -eq $false)
write-output 'Complete execution'

END_COMMAND
) do
      
      its(:stdout) { should match /Extract the file/i }
      its(:stdout) { should match /Load assembly/i }
      its(:stdout) { should match /Throw sample assertion exception/i }
      its(:stdout) { should match /Complete execution/i }
      its(:stderr) { should match /Exception/ }
      its(:stderr) { should match /Expected: True/ }
      its(:stderr) { should match /But was:  False/ }
      its(:exit_status) { should == 1 } 
    end
  end
  context 'download .net assembly for execution' do
      @url =  'http://github.com/nunit/nunitv2/releases/download/2.6.4/NUnit-2.6.4.zip' 
      @download_path =  'c:/temp' 
      @file =  'nunit.zip' 
    describe command(<<-END_COMMAND
write-output 'pre_command was success';
write-output 'main command is run';

write-output 'Check the file is present'
\$zip_path = '#{@download_path}/#{@file}'
test-path -LiteralPath \$zip_path -ErrorAction Stop
write-output 'extract the file'
[string]\$extract_path = ('{0}\\Desktop\\Extract' -f \$env:USERPROFILE)
[System.IO.Directory]::CreateDirectory(\$extract_path)
add-type  -AssemblyName 'System.IO.Compression.FileSystem'
[System.IO.Compression.ZipFile]::ExtractToDirectory(\$zip_path, \$extract_path)
\$dll_name = 'nunit.framework.dll'
write-output 'load assembly'
add-type -path ('{0}\\Desktop\\Extract\\NUnit-2.6.4\\bin\\{1}' -f \$env:USERPROFILE , \$dll_name)
write-output 'throw assertion exception'
[NUnit.Framework.Assert]::IsTrue(\$true -eq \$false)
write-output 'complete execution'
return \$true
END_COMMAND
) do
# NOTE: avoid using \$true - too much interpolation
      let(:pre_command_script) { "(new-object -typename 'System.Net.WebClient').DownloadFile('#{@url}','#{@download_path}/#{@file}'); write-host 'return -1'; return -1" }
      let (:pre_command) do 
      #NOTE: cannot make assignments inside [ScriptBlock]::Create
      # overall looks ugly and brittle
      pre_command =  <<-END
( Invoke-Command -ScriptBlock ([Scriptblock]::Create("#{pre_command_script}"))) -eq -1 
END
      pre_command.gsub!(/\r?\n/,' ')
      end
      its(:stdout) { should match /main command/ }
      its(:stdout) { should match /pre_command/ }
      its(:stdout) { should match /extract the file/ }
      its(:stdout) { should match /load assembly/ }
      its(:stdout) { should match /throw assertion exception/ }
      its(:stdout) { should match /complete execution/ }
      its(:stderr) { should match /Exception/ }
      its(:stderr) { should match /Expected: True/ }
      its(:stderr) { should match /But was:  False/ }
      its(:exit_status) { should == 1 } 
    end
  end
end
