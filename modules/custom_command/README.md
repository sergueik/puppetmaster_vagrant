Info
----
This module is a Powershell script designed 
The script is simply a [wrapper for `schtasks.exe` utility](http://stackoverflow.com/questions/18387920/get-scheduledtask-in-powershell-on-windows-server-2003). It was originally designed for and tested against Windows 7 guest as a quick solution for installing legacy applications which lack a console (silent) installer (even if the desktop access is required for an innocent progress bar).

With Windows Server 2012,Windows 8 and later 
[Scheduled Tasks]( https://technet.microsoft.com/en-us/library/jj649808%28v=wps.630%29.aspx) 
powershell cmdlets have been introduced.

On Windows 7,2008 /  powershell 3 where the [Scheduled Tasks]( https://technet.microsoft.com/en-us/library/jj649808%28v=wps.630%29.aspx) is not available, alternative is to use __Schedule.Service__ [COM object](http://msexchange.me/2013/12/22/schedule-task-monitor-script). The COM object in question was distributed as part of [PowerShell Pack](http://code.msdn.microsoft.com/PowerShellPack), which appears to be retired. For the purpose of this module, `schtasts.exe` appears to be sufficient. Switch to Windows 2012 solution is planned in future revisions.

Usage
-----
Add the following to your site manifest:
```
  custom_command { 'Launch nodepad':
    command => 'notepad.exe',
    script  => 'launch_notepad',
    wait    => true,
  } 
```

and provision your Windows system. This will generate the Powershell script named `launch\_notepad.ps1` in the `TEMP` directory. 
The scipt will generate a Windows Scheduled task named __Launch\_Notepad__
and run it once. After the scheduled task is created and started, Powershell with monitor it to ensure:

* that the state of the task has changed from __Not Ready__ to __Running__ and not __Unable to Start/run__
* the state of the task has changed from __Running__ to __Ready__ indicating that the task has completed. This is important if there are other resourcesthat are ordered to be applied later in the order.

The execution details are logged into the file named `lauch\_notepad.${random}.log` in the `TEMP` directory. 

Multiple declarations of the type are possible within site manifest.


History
-------

 *  0.1.0 initial release as [Puppet class](https://docs.puppetlabs.com/puppet/latest/reference/lang_classes.html)
 *  0.2.0 rewritten as [Puppet defined type](https://docs.puppetlabs.com/puppet/latest/reference/lang_defined_types.html).

Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)

