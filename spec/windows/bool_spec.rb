require_relative '../windows_spec_helper'

context 'Commands' do
  context 'Exitcode' do
    {
      true => 0,
      false => 1,
      false => 2
    }.each do |key,val|
      describe command(<<-EOF

        $status = [bool]$#{key.to_s}
        write-output "Status is ${status}"

        $exit_code  = [int](-not $status ) * $val
        if ($status -is [Boolean] -and $status){
          $exit_code = 0
        } else {
          $exit_code = #{val}
        }
        write-output "exiting with ${exit_code}"
        exit( $exit_code)
      EOF
      ) do
        its(:stdout) { should match /Status is #{key}/i }
        its(:stdout) { should match /exiting with #{val}/i }
        its(:exit_status) { should eq val<<8 }
      end
    end
  end
end