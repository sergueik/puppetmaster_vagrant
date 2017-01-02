context 'Jenkins Plugins' do
  jenkins_home = '/var/lib/jenkins'
  {
    'subversion'=> '1.54',
    'windows-slaves'=> nil,
  }.each do |plugin, version|
    describe file("#{jenkins_home}/plugins/#{plugin}/META-INF") do
      it { should be_directory }
    end
    if ! version.nil?
      describe file("#{jenkins_home}/plugins/#{plugin}/META-INF/MANIFEST.MF") do
        it { should be_file }
        it { should contain( 'Plugin-Version: ' + version ) }
      end
    end
    [
      'pom.properties',
      'pom.xml',
    ].each do |filename|
      describe file("#{jenkins_home}/plugins/#{plugin}/META-INF//maven/org.jenkins-ci.plugins/#{plugin}/#{filename}") do
        it { should be_directory }
      end
    end
  end  
end
