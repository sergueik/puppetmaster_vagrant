# Application init.d script is a wrapper for java runtime launching a certain class via classpath,
# but is not returning its own status correctly -
# preventing one from using specinfra 'service' resource

context 'Specinfra Service Resource Alternative' do

  service_name = 'service_name'
  classpath = 'package.name.ClassName'
  let(:path) do
    '/sbin:/bin:/usr/bin'
  end

  describe service(service_name) do
    # the canonical 'specinfra' appears to broken on RHEL 7
    # specinfra probably falls into negative lookbehind trap
    # https://github.com/mizzy
    it { should be_enabled }
    it { should be_running }
  end

  classpath = classpath.gsub(/^(.)/, '[\1]')

  context 'is stopped' do
    describe command("service #{service_name} status") do
      its(:stdout) { should contain 'not running' }
    end
  end
  context 'is not found by pgrep' do
    # NOTE: specinfra uses sudo
    describe command("pgrep -f '#{classpath}' -l") do
      its(:exit_status) { should eq 1 }
      its(:stdout) do
        should_not match(/\d+/)
        should_not contain 'sudo'
      end
    end
  end
  context 'is running' do
    describe command("service #{service_name} status") do
      # NOTE: negative lookbehind
      its(:stdout) { should match(/(?<!not )running/) }
      its(:stdout) { should_not contain 'not running' }
    end
  end
  context 'is found by pgrep' do
    # NOTE: specinfra uses sudo
    describe command("pgrep -f '#{classpath}' -l") do
      its(:exit_status) { should eq 0 }
      its(:stdout) do
        should match(/\d+/)
        should_not contain 'sudo'
      end
    end
  end
end
