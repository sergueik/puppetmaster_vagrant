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
  info = {
    'Description' => 'The Apache HTTP Server',
    'LoadState'   => 'loaded',
    'ActiveState' => 'active', # 'inactive'  or 'failed' when stopped,
    # 'ExecStart'   => '{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -DFOREGROUND ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }',
    # 'ExecReload'  => '{ path=/usr/sbin/httpd ; argv[]=/usr/sbin/httpd $OPTIONS -k graceful ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }',
    'ExecStop'    => '{ path=/bin/kill ; argv[]=/bin/kill -WINCH ${MAINPID} ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }',
    'After'       => 'nss-lookup.target systemd-journald.socket system.slice network.target tmp.mount -.mount basic.target remote-fs.target',
  }
  info_regexp = '(:?' + info.keys.join('|') + ')'
  describe command("systemctl --no-page show httpd | grep -E '#{info_regexp}=' ") do
    info.each do |key,val|
      # #escape does not work
      # its(:stdout) { should contain Regexp.new(key + '=' + Regexp.escape(val)) }
      its(:stdout) { should contain key + '=' + val }
      # #escape will not handle properly
      line = val
            {
        '\\' => '\\\\\\\\',
        '$'  => '\\\\$',
        '+'  => '\\\\+',
        '?'  => '\\\\?',
        '-'  => '\\\\-',
        '*'  => '\\\\*',
        '{'  => '\\\\{',
        '}'  => '\\\\}',
        '('  => '\\(',
        ')'  => '\\)',
        '['  => '\\[',
        ']'  => '\\]',
        ' '  => '\\s*',
      }.each do |s,r|
        line.gsub!(s,r)
      end
      # home-brewed regexp escape does not work
      # its(:stdout) do
      #   should contain Regexp.new(key + '=' + line, Regexp::IGNORECASE )
      # end
    end
  end
end
