require 'spec_helper'

context 'Tomcat in Java Proces List' do
  context 'Bootstrp process check' do
    catalina_bootstrap_class = 'org.apache.catalina.startup.Bootstrap'
    jps_class = 'sun.tools.js.Jps'
    describe command('jps -m') do
      its(:stdout) { should contain 'Bootstrap start'}
      its(:exit_status) { should_not be 0}
    end
    describe command('jps -ml') do
      its(:stdout) { should match /#{catalna_bootstrap_class} start/}
      its(:stdout) { should contain jps_clas }
      its(:exit_status) { should_not be 0}
    end
  end
end
