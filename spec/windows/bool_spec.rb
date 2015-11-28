require_relative '../windows_spec_helper'

context 'Commands' do
  context 'exitcode' do
    {
    'true' => 0,
    'false' => 1 }.each do |k,v| 
      describe command(<<-END_COMMAND
$status = [bool]$#{k}
$exit_code  = [int](-not $status )
write-output "exiting with ${exit_code}"

if (($status -eq 1 ) -or ($status -is [Boolean] -and $status)){ 
  $exit_code = 0 
} else { 
  $exit_code = 1 
} 
write-output "exiting with ${exit_code}"
exit $exit_code
END_COMMAND
)     do
        its(:stdout) { should match /exiting with #{v}/i }
        its(:exit_status) { should eq "#{v}".to_i } 
      end
    end
  end
end

