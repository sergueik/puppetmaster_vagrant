require 'spec_helper'

context 'lynx' do

  context 'availability' do
    describe command('which lynx') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match Regexp.new('/bin/lynx', Regexp::IGNORECASE) }
      its(:stderr) { should be_empty }
    end
  end
  context 'querying JSON' do
   web_root = '/var/www/html'
   datafile = 'example.html'

   before(:each) do
    # NOTE:  avoid using bash vars in the example below
    Specinfra::Runner::run_command( <<-EOF
      cat <<END>#{web_root}/#{datafile}
        <!DOCTYPE html>
        <html>
        <body>
        <pre>
        grep -qiE &quot;error&quot; &apos;/tmp/a.log&apos; &gt; /dev/null
        if [[ $? -eq 0 ]]
        then
          echo &quot;ERROR&quot;
        fi
        </pre>
        </body>
        </html>
END
    EOF
  )
  end

    # Lynx would render pre
    describe command(<<-EOF
      URL='http://localhost/#{datafile}'
      lynx -dump ${URL}
    EOF
    ) do
      [
        "grep -qiE \ʼ"error\"ʼ '/tmp/a.log' > /dev/null",
        'if [[ $? -eq 0 ]]',
        'then',
        '  echo "ERROR"',
        'fi',
      ].each do |line|
        its(:stdout) { should contain line }
      end
      its(:stderr) { should be_empty }
    end
  end
end
