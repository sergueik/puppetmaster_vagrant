require_relative '../windows_spec_helper'

context 'Md5 Checksum' do
  file_path = 'C:\windows'
  file_name = 'notepad.exe'
  describe command("<<-EOF

$file_name = '#{file_name}' 
$file_path = '#{file_path}' 
$expected_md5_checksum   = '#{md5_checksum}'
$o = new-object -TypeName 'System.Security.Cryptography.MD5CryptoServiceProvider'
write-output ('{0} *{1}' -f $file_name, [System.BitConverter]::ToString($o.ComputeHash([System.IO.File]::ReadAllBytes(Path.Combine($file_path,$file_name)))))
# BitConverter.ToString(Byte[]) method produces string of hexadecimal pairs separated by hyphens, 
# where each pair represents the corresponding element in value: '7F-2C-4A-00-...'
$actual_md5_checksum = [System.BitConverter]::ToString($o.ComputeHash([System.IO.File]::ReadAllBytes($file_path))).Replace('-', '')
write-output "status = ${status}" 
$status = [int] (-not ( $actual_md5_checksum -eq $expected_md5_checksum ))

exit $status 


  EOF
  ) do
    its(:stdout) { should match /[tT]rue/ }
    its(:exit_status) { should eq 0 }
  end
end
