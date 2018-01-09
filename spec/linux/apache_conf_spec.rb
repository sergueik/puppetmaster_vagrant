require 'spec_helper'

# examine apache virtual host and confirm that it has specific rues and they are not commented out
context 'Apache configuration' do
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
