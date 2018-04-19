require 'spec_helper'

context 'Log globbing' do
  filecount = 0
  puts "d:/apps/#{agent_homedir}/var/log/service_*.log"
  Dir.glob("d:/apps/#{agent_homedir}/var/log/service_*.log").each do |filename|
    puts filename
    describe file(filename) do
      it { should be_file }
    end
    #  [
    #    'Logging configured',
    #    'Agent started',
    #    'Starting Services',
    #    'Services started',
    #    'JMS communication started',
    #    'Connecting to server',
    #    'Connection to server established'
    #  ].each do |line|
    #    it { should contain line }
    #  end
    filecount = filecount + 1
  end
  describe(filecount) do
    it { should_not be 0 }
  end
end
