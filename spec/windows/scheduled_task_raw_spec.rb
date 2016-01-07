require_relative '../windows_spec_helper'
context 'Scheduled Tasks' do
  program_directory = 'Program Directory'
  program = "..."
  arguments = "..."
  context 'Application Task Scheduler configuration' do
    describe file('C:/Programdata/LogRotate_scheduled_task.xml') do
      it { should exist }
      it { should be_file }
      [
          '<Command>"C:\\\\Program Files\\\\#{program_directory}\\\\#{program}"</Command>',
          "<Arguments>#{arguments}</Arguments>",
          '<WorkingDirectory>c:\\\\windows\\\\temp</WorkingDirectory>'
      ].each do |line|
        it { should contain /#{Regexp.new(line)}/i }
      end
      it { should contain '<Task xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task" version="1.3">' }
      it { should contain '<UserId>S-1-5-18</UserId>' }

    end
  end

  context 'Application Task Scheduler' do
    
    describe command(<<-EOF
schtasks.exe /Query /TN #{name} /xml
             EOF
             ) do
      its(:exit_status) { should eq 0 }
      [
          '<Command>"C:\\\\Program Files \\(x86\\)\\\\#{program_directory}\\\\#{program}"</Command>',
          "<Arguments>#{arguments}</Arguments>",
          '<WorkingDirectory>c:\\\\windows\\\\temp</WorkingDirectory>'
      ].each do |line|
        its(:stdout) { should match /#{Regexp.new(line)}/i }
      end
    end
  end
end
