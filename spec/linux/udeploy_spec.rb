require 'spec_helper'

context 'udeploy' do
  # udeploy is provisioned by Puppet but later may be removed by udeploy master server
  package_name = 'udeploy'
  package_state = command("/opt/puppetlbs/bin/puppet resource package '#{package_name}'").stdout
  if package_state != /ensure => 'purged'/
    context 'Process' do
      app_jar = 'air-monitor.jar'
      app_user = 'udeploy'
      describe command("/bin/pgrep -a java -u #{app_user}") do
        its(:stdout) {should match app_jar }
      end
    end
    context 'Directory' do
      app_homedir = '/opt/udeploy'
      %w|
      bin
      conf
      lib
      var
      |.each do |folder|
        describe file("#{app_homedir}/#{folder}") do
          it { should_be directory }
        end
      end
    end
      # more app-specific tests
  else
    # package was removed
  end
end
