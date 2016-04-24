require_relative '../windows_spec_helper'

context 'Test with initial delay' do

  package_name = 'Puppet Enterprise'
  version = '3.2.2'
  context 'Package Test with initial delay' do
    before(:each) do
      delay = 1000
      repeat = 10
      log  = 'c:/windows/temp/sleeep.log'
      Specinfra::Runner::run_command(<<-END_COMMAND
      
      $delay = #{delay}
      $repeat = #{repeat}
      $log = '#{log}'
      0..$repeat | foreach-object { 
        $round = $_ 
        write-output ('round {0}' -f $round) | out-file $log -append -encoding 'ascii'
        start-sleep -millisecond $delay
        $test = $false
        # do any reasonable check to abort the loop
        if ($test) {
          exit
        }
        # can verify from the size of the $log, how many times the code was run
      }
      END_COMMAND
      ) 
    end
    describe package(package_name) do
      it { should be_installed.with_version( version ) } 
    end
  end
end
