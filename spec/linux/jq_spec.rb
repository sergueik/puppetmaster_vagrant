require 'spec_helper'

context 'jq' do

  context 'availability' do
    describe command('which jq') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new('/bin/jq', Regexp::IGNORECASE) }
      its(:stderr) { should be_empty }
    end
  end
  context 'querying JSON' do

   datafile = '/tmp/sample.json'

   before(:each) do
    Specinfra::Runner::run_command( <<-EOF
      cat <<END>#{datafile}
{
"code": 401
}
END
  EOF
  )
  end

    # Tomcat configuration is heavily name-spaced
    describe command(<<-EOF

      DATAFILE='#{datafile}'
      jq -r '.code' < ${DATAFILE}

    EOF
    ) do
      its(:stdout) { should contain '401' }
      its(:stderr) { should be_empty }
    end
  end
end
