require 'spec_helper'

# examine apache virtual host and confirm that it has specific rues and they are not commented out
context 'Apache configuration' do
  context 'Virtual Host settings' do
    describe file('/etc/httpd/conf.d/vhost.conf') do
      [
        'ProxyRequests Off',
        'ProxyPreserveHost On',
        'RewriteEngine On',
        'RewriteCond %{HTTP_USER_AGENT} ^MSIE',
        'RewriteRule ^index\.html$ welcome.html',
      ].each do |line|
        # NOTE: Regexp.escape -> String
        its(:content) { should match "^\s*" + Regexp.escape(line) }
      end
    end
  end
  context 'Global Settings' do
    context 'Vanilla' do
      describe command('curl -k -I http://localhost') do
        # default Apache response header delivered for '/etc/httpd/conf/httpd.conf' configuration
        # ServerTokens OS 
        its(:stdout) { should match /Server: Apache/ }
        # double negative, see below
        its(:stdout) { should_not match( Regexp.new("Server: Apache(?!/[0-9.]+)(?!/\([a-zA-Z.]+\)).*$")) }
        # explicit match of the
        its(:stdout) { should match /Server: Apache\/\d\.\d+\.\d+ *\((?:Unix|CentOS)\)/i }
      end
    end
    context 'Rectified'  do
      # https://www.virendrachandak.com/techtalk/how-to-hide-apache-information-with-servertokens-and-serversignature-directives/
      describe file('/etc/httpd/conf/httpd.conf') do
        [
          'ServerTokens Prod',
        ].each do |line|
          its(:content) { should match "^\s*" + Regexp.escape(line) }
        end
      end
      describe command('curl -k -I http://localhost') do
        its(:stdout) { should match /Server: Apache/ }
        # negative lookahead 
        its(:stdout) { should match( Regexp.new("Server: Apache(?!/[0-9.]+)(?!/\([a-zA-Z.]+\)).*$")) }
        # explicit negative match via RSpec DSL
        its(:stdout) { should_not match /Server: Apache\/\d\.\d+\.\d+ *\((?:Unix|CentOS)\)/i }
      end
    end
  end
end
