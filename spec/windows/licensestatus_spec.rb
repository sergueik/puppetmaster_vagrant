require_relative '../windows_spec_helper'

# http://stackoverflow.com/questions/29368414/need-script-to-find-server-activation-status
# http://blog.tyang.org/2015/01/08/detecting-windows-license-activation-status-using-configmgr-dcm-opsmgr/

context 'License Status' do

  describe command (<<-EOF
    # License Status codes:
    $license_status_codes = @{
      '0' = 'Unlicensed';
      '1' = 'Licensed';
      '2' = 'Out-of-Box Grace Period';
      '3' = 'Out-of-Tolerance Grace Period';
      '4' = 'Non-Genuine Grace Period';
      '5' = 'Notification';
      '6' = 'ExtendedGrace';
    }

    # Terse form, requires Powershell 3.0 to parse
    # $license_status = Get-CimInstance -ClassName SoftwareLicensingProduct |
    #                   where PartialProductKey |
    #                   select LicenseStatus

    $license_status = get-ciminstance -ClassName SoftwareLicensingProduct |
                      where-object { $_.PartialProductKey -match '\\S' } |
                      select-object -expandproperty LicenseStatus
    write-output ('License status: {0}' -f $license_status )
    write-output ('License status: {0}' -f $license_status_codes[($license_status.tostring())] )
    $license_status_human = switch ($license_status)
    {
      0 { 'Unlicensed' }
      1 { 'Licensed' }
      2 { 'Out-of-Box Grace Period' }
      3 { 'Out-of-Tolerance Grace Period' }
      4 { 'Non-Genuine Grace Period' }
      5 { 'Notification' }
      6 { 'ExtendedGrace' }
    }
    write-output ('License status: {0}' -f $license_status_human )
  EOF
  ) do
    its(:stdout) { should contain Regexp.new('License status: (?:Licensed|Notification)') }

  end
end
