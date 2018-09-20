require 'spec_helper'

context 'Bash tests for unless' do
  # collecting exit code for subsequent filtering ignorable nonzero exit codes like e.g. 130 for ping
  # sound exit codes are just
  # Success: code 0
  # No reply: code 1
  # Other errors: code 2
  # http://tldp.org/LDP/abs/html/exitcodes.html
  {
  'www.google.com'    => 0,
  '128.0.0.0  '       => 1,  # Destination Host Unreachable
  'www.gaaaaagle.com' => 2, # ping: www.gaaaaagle.com: Name or service not known
  }.each do |hostname, exit_code|
    context 'Loading exit status into shell variable' do
      describe command(<<-EOF
        HOSTNAME='#{hostname}'
        EXITCODE=0
        ping -c 1 $HOSTNAME > /dev/null 2>&1; eval "EXITCODE=$?";
        if [[ $EXITCODE -ne 130 ]] 
        then
          printf 'Exit code is %d\\n' $EXITCODE
        fi
      EOF
      ) do
        its(:stdout) { should contain Regexp.new(Regexp.escape("Exit code is #{exit_code}")) }
      end
    end
    context 'Loading exit status into shell variable via trap' do
      describe command(<<-EOF
        HOSTNAME='#{hostname}'
        for RESULT in $(trap 'eval "EXITCODE=$?"; echo $EXITCODE' 0; (ping -c 1 $HOSTNAME > /dev/null 2>&1))
        do 
          if [[ $RESULT -ne 130 ]] 
          then
            printf 'Exit code is %d\\n' $RESULT
          fi
        done
      EOF
      ) do
        its(:stdout) { should contain Regexp.new(Regexp.escape("Exit code is #{exit_code}")) }
      end
    end
  end
end
