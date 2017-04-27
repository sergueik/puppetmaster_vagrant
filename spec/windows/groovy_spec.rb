require 'spec_helper'

context 'Groovy' do
  java_version = '1.8.0_101'
  groovy_version = '2.3.8'

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
  # passes on Windows 7 / uru, fails on Windows 2008 / speinfra / vagrant-serverspec
  describe command(<<-EOF
    $env:JAVA_HOME='C:\\java\\jdk#{java_version}'
    & "C:\\java\\groovy-#{groovy_version}\\bin\\groovy.bat" "-version"
  EOF
  ) do
   its (:stdout) { should contain "Groovy Version: #{groovy_version}" }
  end
  describe command("& \"C:\\java\\groovy-#{groovy_version}\\bin\\groovy.bat\" \"-version\"") do
   let (:java_home) {"C:\\java\\jdk#{java_version}"} # setting arbitrary env does not work
   its (:stdout) { should_not contain "Groovy Version: #{groovy_version}" }
  end
  describe command("& \"C:\\java\\groovy-#{groovy_version}\\bin\\groovy.bat\" \"-version\"") do
   let (:path) {"C:\\java\\jdk#{java_version}\\bin"}
   its (:stdout) { should contain "Groovy Version: #{groovy_version}" }
  end
  describe command( <<-EOF
    $groovy_version='#{groovy_version}'
    $java_version='#{java_version}'      
    [Environment]::SetEnvironmentVariable('JAVA_HOME', "c:\\java\\jdk${java_version}", 'PROCESS' )
    write-output '' | out-file 'c:\\windows\\temp\\a.cmd' -encoding ASCII
    write-output "set JAVA_HOME=c:\\java\\jdk${java_version}" | out-file 'c:\\windows\\temp\\a.cmd' -encoding ASCII -append 
    write-output "dir %JAVA_HOME%" | out-file 'c:\\windows\\temp\\a.cmd' -encoding ASCII -append 
    write-output "c:\\Java\\groovy-${groovy_version}\\bin\\groovy.bat -version" | out-file 'c:\\windows\\temp\\a.cmd' -encoding ASCII -append 
    & 'c:\\windows\\temp\\a.cmd'
  EOF
  ) do
    its(:stdout){ should match /Groovy Version: #{groovy_version}/io }
  end
end