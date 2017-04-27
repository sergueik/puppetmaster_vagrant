require 'spec_helper'

context 'Groovy' do
  java_version = '1.8.0_101'
  groovy_version = '2.3.8'

  # passes on Windows 7 / uru, fails on Windows 2008 / speinfra / vagrant-serverspec
  describe command("& C:\\\\java\\\\groovy-#{groovy_version}\\\\bin\\\\groovy.bat --version") do
    [
      'ERROR: Environment variable JAVA_HOME has not been set.',
      'Attempting to find JAVA_HOME from PATH also failed.',
      'Please set the JAVA_HOME variable in your environment',
      'to match the location of your Java installation.',
    ].each do |line|
     its (:stdout) { should contain line }
    end
  end
  describe command(<<-EOF
$env:JAVA_HOME='C:\\java\\jdk1.8.0_101'
& C:\\java\\groovy-2.3.8\\bin\\groovy.bat --version
EOF
) do
   its (:stdout) { should contain 'Groovy Version: 2.3.8' }
  end
  describe command('& C:\\java\\groovy-2.3.8\\bin\\groovy.bat --version') do
   let (:java_home) {'C:\\java\\jdk1.8.0_101'} # setting artitrary env does not work
   its (:stdout) { should_not contain 'Groovy Version: 2.3.8' }
  end
end