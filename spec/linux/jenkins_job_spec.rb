require 'spec_helper'

context 'Jenkins jobs' do
  jenkins_home = '/var/lib/jenkins'
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
