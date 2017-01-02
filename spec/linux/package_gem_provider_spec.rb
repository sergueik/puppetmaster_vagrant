context 'Packages installed by gem provider' do
  {
    'linux-kstat' => '0.1.3',
    'sensu-plugin' => nil, 
  }.each do |package_name, package_version|
    describe command("/bin/gem list --installed --local #{package_name}") do
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
      its(:stdout) { should match /true/ }
    end      
    describe command("/bin/gem list --local #{package_name}") do
      its(:stderr) { should be_empty }
      its(:exit_status) {should eq 0 }
        its(:stdout) { should match Regexp.new(package_name) }
      if package_version
        its(:stdout) { should match Regexp.new(package_version) }
      end
    end      
    describe package(package_name) do
      # specinfra issue ?
      if package_version
        it { should be_installed.by('gem').with_version(package_version)  }
      else
        it { should be_installed.by('gem') }
      end
    end
  end  
end
