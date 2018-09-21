require 'spec_helper'
require 'pp'

context 'Verifying Base64 encoded  basic auth header', :if => ENV.has_key?('URU_INVOKER') do
  context 'Ruby side' do
    encoded_string = 'Zm9vOmJhcgo=' # base64('encode', 'foo:bar')
    datafile = '/tmp/sample.yaml'
    username = 'foo'
    jvm_setting = 'package.Class.method.header'
    # password = 'bar'
    before(:each) do
      Specinfra::Runner::run_command( <<-EOF
        # indent matters
        cat <<END>#{datafile}
  -Dfile.encoding=UTF-8 -D#{jvm_setting}=#{encoded_string}
END
    EOF
    )
    end
    describe command(<<-EOF
      cat '#{datafile}' | sed -e 's/\\-D/\\n/g' | sed -n 's/#{jvm_setting}=//p' | base64 -d -
    EOF
    ) do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new("#{username}:.*", Regexp::IGNORECASE) }
      its(:stderr) { should_not match 'invalid input' }
    end
  end
end
