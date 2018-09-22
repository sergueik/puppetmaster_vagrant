require 'spec_helper'
require 'base64'
require 'pp'

context 'Verifying Base64 encoded  basic auth header', :if => ENV.has_key?('URU_INVOKER') do
  encoded_string = 'Zm9vOmJhcgo=' # base64('encode', 'foo:bar')
  username = 'foo'
  jvm_setting = 'package.Class.method.header'
  # password = 'bar'
  context 'Standard tools' do
    datafile = '/tmp/sample.yaml'
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
  context 'Ruby side processing' do
    command_result = command("/bin/echo '-Dfile.encoding=UTF-8 -D#{jvm_setting}=#{encoded_string}'").stdout
    answer = begin
      $stderr.puts 'Base64 test'
      $stderr.puts command_result
      scan_result = command_result.scan(/(?:\-D#{jvm_setting}=)(.*)\b/i)
      pp scan_result
      if scan_result != []
        data = scan_result[0][0]
        $stderr.puts data
        if data.nil?
          data = encoded_string
        end
        @res = Base64.decode64(data)
        $stderr.puts @res
        @res
      else 
        nil
      end
    rescue => e
      $stderr.puts e.to_s
      nil
    end
    pp answer

    describe String(answer) do
      it { should match Regexp.new("#{username}:.*", Regexp::IGNORECASE) }
    end
  end
end
