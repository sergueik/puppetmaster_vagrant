require_relative '../windows_spec_helper'


context 'Md5 Checksum' do
  file_path = 'C:\windows'
  file_name = 'notepad.exe'
  # NOTE:  notepad.exe checksum is Windows release-specific
  # Windows 8.1
  file_checksum = 'fc2ea5bd5307d2cfa5aaa38e0c0ddce9'
  # Windows 7
  file_checksum = 'd378bffb70923139d6a4f546864aa61c'

  # based on http://poshcode.org/6639
  describe command(<<-EOF

    $file_name = '#{file_name}'
    $file_path = '#{file_path}'
    $file_checksum = '#file_checksum}'
    # set output field separator
    $OFS = ''
    # NOTE:
    # BitConverter.ToString(Byte[]) produces string of hexadecimal pairs separated by hyphens:
    # [System.BitConverter]::ToString((new-object -TypeName 'System.Security.Cryptography.MD5CryptoServiceProvider').ComputeHash([System.IO.File]::ReadAllBytes([System.IO.Path]::Combine($file_path,$file_name))))
    # 'FC-2E-A5-BD-53-...'
    # one can use .Replace('-', '')

    $hashes = @{}
    foreach ($type in @( 'MD5','SHA1','SHA256','SHA384','SHA512','RIPEMD160')) {
      $o = [Security.Cryptography.HashAlgorithm]::Create($type)
      [string]$hash = $o.ComputeHash([IO.File]::ReadAllBytes([System.IO.Path]::Combine($file_path,$file_name))) | foreach-object { '{0:x2}' -f $_ }
      # [System.BitConverter]::ToString
      $hashes.$Type = $hash
    }

    foreach ($o in $hashes.GetEnumerator()) {
      write-output ('{0,-9} {1}' -f $o.Name,$o.Value)
    }
    # Powershsell 3 syntax:
    $status = (($hashes.Values -eq $file_checksum).Count -ge 1)
    # plain C# class method 
    $status =  $hashes.ContainsValue($file_checksum)
    # TODO:  debug the difference in behavior under RSpec
    $exit_code = [int](-not ($status))
    write-output "status = ${status}"
    write-output "exit_code = ${exit_code}"

    exit $exit_code
  EOF
  ) do
    its(:stdout) { should match /#{file_checksum}/ }
    its(:stdout) { should match /[tT]rue/ }
    its(:exit_status) { should eq 0 }
  end
end
