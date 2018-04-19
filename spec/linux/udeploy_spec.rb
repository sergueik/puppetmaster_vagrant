require 'spec_helper'

context 'udeploy' do
  # udeploy or buildforge agent are provisioned by Puppet but later may
  # become managed and can be removed by udeploy master server
  package_name = 'udeploy'
  application_jar = 'air-monitor.jar'
  service_user = 'udeploy'
  package_state = command("/opt/puppetlbs/bin/puppet resource package '#{package_name}'").stdout
  if package_state != /ensure => 'purged'/
    context 'Process' do
      # there may be multiple java processes and
      # the specinfra `process` type will fail to examine the right one
      # running underlying command explicitly
      describe command("/bin/pgrep -a java -u #{service_user}") do
        its(:stdout) { should match application_jar }
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
  else
    # package was removed
    # all app-specific tests are to be skipped
  end
end
