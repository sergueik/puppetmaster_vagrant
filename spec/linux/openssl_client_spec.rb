require 'spec_helper'
#
# origin: http://securityevaluators.com/knowledge/blog/20151102-openssl_and_ciphers/
context 'SSL ciphers and Protocols' do
  host = 'localhost'
  port = '8443'
  protocols = 'ssl2 ssl3 tls1 tls1_1 tls1_2'
  protocol = 'tls1_2'
  ciphers = [
    'AES256-GCM-SHA384',
    'AES256-SHA256',
    'AES256-SHA',
    'AES128-GCM-SHA256',
    'AES128-SHA256',
    'AES128-SHA',
  ]
  describe command(<<-EOF
    HOST='#{host}';\\
    PORT='#{port}';\\
    PROTOCOLS='#{protocols}' ;\\
    for protocol in $PROTOCOLS; do \\
    for cipher in $(openssl ciphers 'ALL:eNULL' | tr ':' ' '); do \\
    openssl s_client -connect $HOST:$PORT -cipher $cipher -$prototol < /dev/null > /dev/null 2>&1 && echo -e "$protocol:\\t$cipher"; \\
    done; \\
    done
  EOF
  ) do
    # its(:exit_status) { should eq 0 }
    ciphers.each do |cipher|
      its(:stdout) { should match Regexp.new(protocol + ':\s+' + cipher, Regexp::IGNORECASE) }
      # TODO: negative lookahead
    end
    its(:stderr) { should be_empty }
  end
end
