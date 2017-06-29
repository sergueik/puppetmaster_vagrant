require_relative '../windows_spec_helper'

context 'NDP Versions' do
  # based on https://raw.githubusercontent.com/lazywinadmin/PowerShell/master/TOOL-Get-NetFramework/Get-NetFramework.ps1
  context 'Cmdlet' do
    describe command(<<-EOF
      function Get-NetFramework {
          $netFramework = Get-ChildItem -Path 'HKLM:/SOFTWARE/Microsoft/NET Framework Setup/NDP' -recurse |
          Get-ItemProperty -name Version -EA 0 |
          Where-Object { $_.PSChildName -match '^(?!S)\\p{L}' } |
          Select-Object -Property PSChildName, Version ;
          write-output $netFramework

      }
      Get-NetFramework
    EOF
    ) do
    # NOTE: warning: key "Client" is duplicated and overritten
      {
      'v3.5  ' => '3.5.30729.5420',
      'Client' => '4.5.50938',
      'Full' => '4.5.50938',
      'Client' => '4.0.0.0',
      }.each do |key,val|
        its(:stdout) { should contain /#{key}\s+#{val}/ }
      end
    end
  end
end