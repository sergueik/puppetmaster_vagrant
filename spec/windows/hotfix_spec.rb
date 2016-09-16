require_relative '../windows_spec_helper'

context 'Hotfix' do
  hotfix_id = 'KB976932'
  describe command(<<-EOF
    $hotfix_id = '#{hotfix_id}'
    $keys = (get-wmiobject -class 'win32_quickfixengineering')
    $status = (@($keys | where-object { $_.hotfixid -eq $hotfix_id } ).length -gt 0 )
    write-output $status
    if ($status -is [Boolean] -and $status){ $exit_code = 0 } else { $exit_code = 1 }
    exit $exit_code
  EOF
  ) do
    its(:stdout) { should match /true/i }
    its(:exit_status) { should == 0 }
  end
  describe windows_hot_fix('KB976932') do
    it { should be_installed }
  end
end

