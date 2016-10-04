require_relative '../windows_spec_helper'
# see also: https://github.com/gregzakh/alt-p
s# http://referencesource.microsoft.com/#mscorlib/microsoft/win32/fusionwrap.cs,0c272b085a297194,references

context 'Print GAC information about specific assembly' do
  assembly_name = 'WindowsFormsIntegration'
  token = '31bf3856ad364e35'
  describe command(<<-EOF

  function Find-Assembly {
    param(
      [Parameter(ValueFromPipeline=$true)]
      [String]$AssemblyName # find specified assembly
      # when nothing specified - every assembly in the GAC will be printed
    )

    $result = New-Object Collections.ArrayList
    $ASM_CACHE = @{GAC = 2 ;
                   ZAP = 1;  }
    [Object].Assembly.GetType(
      'Microsoft.Win32.Fusion'
    ).GetMethod(
      'ReadCache'
    ).Invoke($null, @(
      [Collections.ArrayList]$result,
      $(if ([String]::IsNullOrEmpty($AssemblyName)) {
        $null
      }
      else {
        $AssemblyName
      }),
      [UInt32]$ASM_CACHE.GAC
    ))
    # TODO: not formatted
    $result
  }
  Find-Assembly -AssemblyName '#{assembly_name}'
  EOF
  )
  do
  [
  "#{assembly_name}, Version=3.0.0.0, Culture=neutral, PublicKeyToken=#{token}",
  "#{assembly_name}, Version=4.0.0.0, Culture=neutral, PublicKeyToken=#{token}"
  ].each do |line|
    its(:stdout) { should contain line }
  end
end
