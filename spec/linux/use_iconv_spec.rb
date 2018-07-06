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
  # alternatively command systemctl to format output in the list format
  describe command('systemctl --no-page show httpd |  grep -E "(?:Description|LoadState|ActiveState)"') do
    {
      'Descipription' => 'The Apache HTTP Server',
      'LoadState' => 'loaded',
      'AcriveState' => 'active',
    }.each do |key,val|
      its(:stdout) { should contain Regexp.new(Regexp.escape( key + '=' + val )) }
    end
  end
end
