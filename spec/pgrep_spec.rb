
# Application init.d script is a wrapper for java runtime launching a certain class via classpath, 
# but is not returning its own status correctly - 
# preventing one from using specinfra 'service' resource

context 'Specinfra Service Resource Alternative' do 

  service_name = 'service_name'
  class_path = 'com.sun.java.package.name.ClassName'

  class_path = class_path.gsub(/^(.)/, '[\1]')

  context 'is stopped' do    
    describe command("/sbin/service #{service_name} status") do
      its(:stdout) { should contain 'not running' }
    end
    # specinfra uses sudo, need to guard against false positives
    describe command("/usr/bin/pgrep -f '#{class_path}' -l") do
      its(:exit_status) { should eq 1 }
      its(:stdout) { should_not match(/\d+/) }
      its(:stdout) { should_not contain 'sudo' }
    end
  end
    
  context 'is running' do    
    describe command("/sbin/service #{service_name} status") do
      # NOTE: negative lookahead failed
      its(:stdout) { should match(/\s+(?!not)\s+running/) }
      its(:stdout) { should_not contain 'not running' }
    end
    describe command("/usr/bin/pgrep -f '#{class_path}' -l") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/\d+/) }
      its(:stdout) { should_not contain 'sudo' }
    end
  end
end  
