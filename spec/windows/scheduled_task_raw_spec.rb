require_relative '../windows_spec_helper'
context 'Scheduled Tasks' do

  program_directory = 'Program Directory'
  program = "<program that is run>"
  arguments = "<arguments>"
  xml_file = "<xml file>"
  context 'Application Task Scheduler configuration' do
    context 'From XML File' do
      describe file("C:/Programdata/#{xml_file}") do
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
    # The test below will only work if the Job was created via Powershell command
    #  register-scheduledjob -name ... -jobtrigger ... -scriptblock ... -scheduledjoboption
    
    context 'Powershell 3.0 and above' do
      describe command(<<-EOF
        get-scheduledjob -name '#{name}'
               EOF
               ) do
        its(:exit_status) { should eq 0 }
        # [Microsoft.PowerShell.ScheduledJob.ScheduledJobDefinition] properties
        {        
          'Command' => '...',
          'Credential' => '...',
          'Definition' => '...',
          'Enabled' => '...',
          'ExecutionHistoryLength' => '...',
          'GlobalId' => '...',
          'Id' => '...',
          'InvocationInfo' => '...',
          'JobTriggers' => '...',
          'Name' => '...',
          'Options' => '...',
        }.each do |key,value|
          its(:stdout) { should match Regexp.new(line) }
        end
      end
      describe command(<<-EOF
        get-jobtrigger -name '#{name}'
               EOF
               ) do
        its(:exit_status) { should eq 0 }
        
        # [Microsoft.PowerShell.ScheduledJob.ScheduledJobTrigger] properties
        {
          'At' => '...',
          'DaysOfWeek' => '...',
          'Enabled' => '...',
          'Frequency' => '...',
          'Id' => '...',
          'Interval' => '...',
          'JobDefinition' => '...',
          'RandomDelay' => '...',
          'RepetitionDuration' => '...',
          'RepetitionInterval' => '...',
          'User' => '...',
        }.each do |key,value|
          its(:stdout) { should match Regexp.new(line) }
        end
      end
      describe command(<<-EOF
        get-scheduledjoboption -name '#{name}'
               EOF
               ) do
        its(:exit_status) { should eq 0 }
        # [Microsoft.PowerShell.ScheduledJob.ScheduledJobOptions] properties
        {
          'DoNotAllowDemandStart' => '...',
          'IdleDuration' => '...',
          'IdleTimeout' => '...',
          'JobDefinition' => '...',
          'MultipleInstancePolicy' => '...',
          'RestartOnIdleResume' => '...',
          'RunElevated' => '...',
          'RunWithoutNetwork' => '...',
          'ShowInTaskScheduler' => '...',
          'StartIfNotIdle' => '...',
          'StartIfOnBatteries' => '...',
          'StopIfGoingOffIdle' => '...',
          'StopIfGoingOnBatteries' => '...',
          'WakeToRun' => '...',
        }.each do |key,value|
          # line =
          its(:stdout) { should match Regexp.new(line) }
        end
      end
    
    end

  end
  context 'Application Task Scheduler' do
  
    name = '<name of the job>'
    
    describe command(<<-EOF
      schtasks.exe /Query /TN #{name} /xml
             EOF
             ) do
      its(:exit_status) { should eq 0 }
      [
          '<Command>"C:\\\\Program Files \\(x86\\)\\\\#{program_directory}\\\\#{program}"</Command>',
          "<Arguments>#{arguments}</Arguments>",
          "<WeeksInterval>1</WeeksInterval>",
          "<Monday />",
          "12:00:00</StartBoundary>",
          '<WorkingDirectory>c:\\\\windows\\\\temp</WorkingDirectory>'
      ].each do |line|
        its(:stdout) { should match Regexp.new(line) }
      end
    end
  end
end
