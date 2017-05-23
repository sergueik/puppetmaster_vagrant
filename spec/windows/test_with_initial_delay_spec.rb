require_relative '../windows_spec_helper'

context 'Test with initial delay' do

  package_name = 'Puppet Enterprise'
  version = '3.2.2'
  context 'Package Test with initial delay' do
    before(:each) do
      delay = 1000
      repeat = 10
      logfile = 'c:/windows/temp/sleeep.log'

      vendor = 'Hewlett Packard Enterprise'
      version = '4.32'
      product = 'HP Enterprise Security Fortify SCA and Applications'
      reg_key = "HKLM:\\SOFTWARE\\Wow6432Node\\#{vendor}\\#{product} #{version}"
      reg_value = 'version' 
      
      Specinfra::Runner::run_command(<<-END_COMMAND
      
      $delay = #{delay}
      $repeat = #{repeat}
      $logfile = '#{logfile}'
      $reg_key = '#{reg_key}'
      $reg_value = '#{reg_value}' 

      0..$repeat | foreach-object { 
        $round = $_ 
        write-output ('round {0}' -f $round) | out-file $log -append -encoding 'ascii'
        start-sleep -millisecond $delay

        $status = $false
        # placeholder for check to abort the loop
        if ($status) {
          exit
        }
        # more realistic case - wait for vendor  registry key is found in the Registry
        $status = $false

        $reg_data = get-itemproperty -path "${reg_key}" -erroraction silentlycontinue | 
          select-object -expandproperty $reg_value
        [bool]$status = ($reg_data -ne $null)
        if ($status) {
          exit
        }
      }
      # NORE: one can inspect the $logfile, how many times the code was run
      END_COMMAND
      ) 
    end
    describe package(package_name) do
      it { should be_installed.with_version( version ) } 
    end
  end
end
