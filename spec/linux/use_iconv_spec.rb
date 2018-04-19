require 'spec_helper'

context 'Converting the command output to cloud-init.log unicode clean' do
  describe command('systemctl status httpd | iconv --from-code UTF8 --to-code US-ASCII -c -') do
    its(:stdout) { should contain Regexp.new(Regexp.escape('* httpd.service - The Apache HTTP Server')) }
  end
  begin
    # the next expectation may fail and abort the process when locale is wrong
    describe command('systemctl status httpd') do
      its(:stdout) { should contain Regexp.new(Regexp.escape('* httpd.service - The Apache HTTP Server')) }
    end
  rescue => e
    $stderr.puts 'Exception (ignored) ' + e.to_s
  end
end

