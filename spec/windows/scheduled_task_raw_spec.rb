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

  context 'Alternative Application Task Scheduler Exam' do
    name = 'application'
    describe command(<<-EOF
      $command_output  = @(& 'schtasks.exe' '--%' '/query /tn "application" /xml ') -join ''
      [System.XML.XMLDocument]$o = new-object -typeName 'System.XML.XMLDocument'
      $o.LoadXML($command_output)
      write-output ('{0} = {1}' -f 'Command', $o.'Task'.'Actions'.'Exec'.'Command')
      write-output ('{0} = {1}' -f 'Arguments', $o.'Task'.'Actions'.'Exec'.'Arguments')
      write-output ('{0} = {1}' -f 'WorkingDirectory', $o.'Task'.'Actions'.'Exec'.'WorkingDirectory' )
      write-output ('{0} = {1}' -f 'UserId', $o.'Task'.'Principals'.'Principal'.'UserId' )
      write-output ('{0} = {1}' -f 'LogonType', $o.'Task'.'Principals'.'Principal'.'LogonType' )
      write-output ('{0} = {1}' -f 'Enabled', $o.'Task'.'Settings'.'Enabled')
      write-output ('{0} = {1}' -f 'DaysInterval', $o.'Task'.'Triggers'.'CalendarTrigger'.'ScheduleByDay'.'DaysInterval')
      EOF
    ) do
      its(:exit_status) { should eq 0 }
      {
        'Command' => 'C:\\\\Program Files \\(x86\\)\\\\LogRotate\\\\logrotate.exe',
        'UserId' => 'System',
        'LogonType' => 'InteractiveTokenOrPassword',
        'Arguments' => '"C:\\\\Program Files \\(x86\\)\\\\LogRotate\\\\Content\\\\sample.conf"',
        'WorkingDirectory' => 'c:\\\\windows\\\\temp',
        'Enabled' => 'True',
        'DaysInterval' => '1',
      }.each do |key, value|
        its(:stdout) {should match /#{Regexp.new(value)}/i }
      end
    end
  end

  context 'Using PSFactoryBuffer' do
    # http://stackoverflow.com/questions/18387920/get-scheduledtask-in-powershell-on-windows-server-2003/25370710#25370710
    name_mask = '^GoogleUpdateTask'
    describe command(<<-EOF
      $schedService = New-Object -ComObject Schedule.Service
      # $schedService | get-member | select-object -property  TypeName
      # System.__ComObject#{2faba4c7-4da9-4013-9697-20cc3fd40f85}
      # {2FABA4C7-4DA9-4013-9697-20CC3FD40F85} is CLSID of (ITaskService)
      # that is a proxy to
      # {9C86F320-DEE3-4DD1-B972-A303F26B061E}
      # which is CLSID of PSFactoryBuffer 'C:\Windows\SysWOW64\TaskSchdPS.dll'
      $schedService.Connect($env:computername)
      $folder = $SchedService.GetFolder('')
      $tasks = $folder.GetTasks('')
      $name_mask = '#{name_mask}'
      $xml_task_description = $tasks | where-object {$_.Name -match $name_mask } | select-object -first 1| foreach-object -membername XML
      [System.XML.XMLDocument]$o = new-object -typeName 'System.XML.XMLDocument'
      $o.LoadXML($xml_task_description)
      write-output ('{0} = {1}' -f 'Command', $o.'Task'.'Actions'.'Exec'.'Command')
      write-output ('{0} = {1}' -f 'Arguments', $o.'Task'.'Actions'.'Exec'.'Arguments')
      write-output ('{0} = {1}' -f 'WorkingDirectory', $o.'Task'.'Actions'.'Exec'.'WorkingDirectory' )
      write-output ('{0} = {1}' -f 'UserId', $o.'Task'.'Principals'.'Principal'.'UserId' )
      write-output ('{0} = {1}' -f 'LogonType', $o.'Task'.'Principals'.'Principal'.'LogonType' )
      write-output ('{0} = {1}' -f 'Enabled', $o.'Task'.'Settings'.'Enabled')
      write-output ('{0} = {1}' -f 'DaysInterval', $o.'Task'.'Triggers'.'CalendarTrigger'.'ScheduleByDay'.'DaysInterval')
      EOF
    ) do
      its(:exit_status) { should eq 0 }
      {
        'Command' => 'C:\\\\Program Files \\(x86\\)\\\\LogRotate\\\\logrotate.exe',
        'UserId' => 'System',
        'LogonType' => 'InteractiveTokenOrPassword',
        'Arguments' => '"C:\\\\Program Files \\(x86\\)\\\\LogRotate\\\\Content\\\\sample.conf"',
        'WorkingDirectory' => 'c:\\\\windows\\\\temp',
        'Enabled' => 'True',
        'DaysInterval' => '1',
      }.each do |key, value|
        its(:stdout) {should match /#{Regexp.new(value)}/i }
      end
    end
  end

end
