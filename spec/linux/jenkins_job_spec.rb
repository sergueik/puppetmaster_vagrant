require 'spec_helper'
require 'pp'
begin
  require 'xmlsimple'
  test_xml = true
rescue LoadError => e
  test_xml = false
end
context 'Jenkins' do
  # on Linux
  jenkins_home = '/var/lib/jenkins'
  # on Windows, arbitrary, e.g.
  jenkins_home = 'C:/java/jenkins.2.321/master/'
  context 'Job directory' do
    [
      'JOB NAME',
    ].each do |job|
      describe file("#{jenkins_home}/jobs/#{job}") do
        it { should be_directory }
      end
      describe file("#{jenkins_home}/jobs/#{job}/config.xml") do
        it { should be_file }
      end
      describe file("#{jenkins_home}/jobs/#{job}/nextBuildNumber") do
        it { should be_file }
      end
    end
  end

  context 'Job configuration' do

    context 'XML schema details' do
      if test_xml 
        {
          'pipeline' =>  [
            'plugin',
            'description',
            'keepDependencies',
            'properties',
            'definition',
            'triggers'
          ],
          'freestyle' => [
            'description',
            'keepDependencies',
            'properties',
            'scm',
            'canRoam',
            'disabled',
            'blockBuildWhenDownstreamBuilding',
            'blockBuildWhenUpstreamBuilding',
            'triggers',
            'concurrentBuild',
            'builders',
            'publishers',
            'buildWrappers'
          ],
          }.each do |type, keys|
          job_name = "test_#{type}"
          config = XmlSimple.xml_in("#{jenkins_home}/jobs/#{job_name}/config.xml")
          pp config.keys
          pp config["plugin"] # {'plugin'=>'workflow-job@2.9',
        end
      else
        puts 'Skipped XML test'
        puts "test_xml = '#{test_xml}'"
      end
    end

    context 'File peek' do
      # for freehand jobs
      #	<?xml version='1.0' encoding='UTF-8'?>
      #	<project>

      # for pipeline jobs
      #	<?xml version='1.0' encoding='UTF-8'?>
      #	<flow-definition plugin='workflow-job@2.9'>
    end
  end
end

context 'Failed attempt to skip XML test', :if => !test_xml do
  puts 'Skipped XML test: '
  puts "test_xml = '#{test_xml}'"
end
