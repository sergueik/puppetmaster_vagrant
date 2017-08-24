require 'spec_helper'

context 'jq' do

  context 'availability' do
  describe command('which jq') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match Regexp.new('/bin/jq', Regexp::IGNORECASE) }
    its(:stderr) { should be_empty }
  end
  end
  context 'querying json' do

   before(:each) do
    json = '/tmp/sample.json'
    Specinfra::Runner::run_command( <<-EOF
      cat <<END>#{json}
{
"code": 401
}
END
  EOF
  )
  end

    #  tomcat configuration is heavily name-spaced
    describe command(<<-EOF
      DATA='#{json}'
      jq -r '.code' < ${DATA}
    EOF
    ) do
      its(:stdout) { should contain '401' }
      its(:stderr) { should be_empty }
    end
  end
end
