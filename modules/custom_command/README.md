Info
----
This module is a Powershell script designed 
The script is simply a [wrapper for `schtasks.exe` utility](http://stackoverflow.com/questions/18387920/get-scheduledtask-in-powershell-on-windows-server-2003). It was originally designed for and tested against Windows 7 guest as a quick solution for installing legacy applications which lack a console (silent) installer (even if the desktop access is required for an innocent progress bar).

With Windows Server 2008 R2, 2012, Windows 8 and later a collection of 
[Scheduled Tasks]( https://technet.microsoft.com/en-us/library/jj649808%28v=wps.630%29.aspx) 
powershell cmdlets have been introduced.

On Windows 7,2008 /  powershell 3 where the [Scheduled Tasks]( https://technet.microsoft.com/en-us/library/jj649808%28v=wps.630%29.aspx) is not available, alternative is to use __Schedule.Service__ [COM object](http://msexchange.me/2013/12/22/schedule-task-monitor-script). The COM object in question was distributed as part of [PowerShell Pack](http://code.msdn.microsoft.com/PowerShellPack), which appears to be retired. For the purpose of this module, `schtasts.exe` appears to be sufficient. Switch to Windows 2012 solution is planned in future revisions: it may offer a more granular conrol over the task state.

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
and run it once. After the scheduled task is created and started, Powershell with monitor it to ensure that:

* state of the task has changed from __Not Ready__ to __Running__ and not __Unable to Start/run__
* state of the task has changed from __Running__ to __Ready__ indicating that the task has completed. This is important if there are other Puppet resources to be applied to the node after this one.

The execution details are logged into the file named `lauch_notepad.${random}.log` in the `TEMP` directory. 

Multiple declarations of the type are possible within site manifest.

![Running notepad.exe via Windows Scheduled Task from Puppet](https://raw.githubusercontent.com/sergueik/puppetmaster_vagrant/master/screenshots/custom_task.png)

Note
----
The objective of this module might be possible to achieve via combination of [scheduled_task](https://docs.puppetlabs.com/references/3.6.latest/type.html#scheduledtask) Puppet resource and [wait_for](https://forge.puppetlabs.com/basti1302/wait_for) custom module, though at the time of developing this module, no actual implementation was found.

Limitations
-----------
In current revision the timeout values to wait for the newly created scheduled task to start and finish are hard-coded in the template / module.

Misc. `custom_command` Module resources
=======================================
These are Puppet wrapper of various basic Powershell command rendered through template designed  to automate removal of registry keys, directories, stopping services, managing Windows system environment etc.

Create Shortcut
===============
Module creates  a Windows shell Link (.LNK) file by invoking Powershell  and calling 'WScript.Shell' COM object as describes in
[stackoverflow](http://stackoverflow.com/questions/28997799/how-to-create-a-run-as-administrator-shortcut-using-powershell)

Sample usage
------------
```
custom_command::exec_shortcut { 'puppet test':
   target_path   => 'c:\Windows\write.exe',
   run_as_admin  => false,
   debug         => false
}

custom_command::exec_shortcut { 'puppet test(admin)':
   target_path  => 'c:\Windows\notepad.exe',
   run_as_admin => true,
}
```
Server Spec Test
----------------
Reads the hex dump of the '.LNK' file using Powershell [snippet](http://windowsitpro.com/powershell/get-hex-dumps-files-powershell) and examines its [binary format](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&cad=rja&uact=8&ved=0CCQQFjABahUKEwiB6Im7le3IAhWI1CYKHdRAAtg&url=https%3A%2F%2Fmsdn.microsoft.com%2Fen-us%2Flibrary%2Fdd871305.aspx&usg=AFQjCNGjKeZ_5uIddVk1gvsf6FJVcSUDVw) specifically looking for LinkCLSID `00021401-0000-0000-C000-000000000046`:
```
  describe command(<<-END_COMMAND
$link_basename = '#{link_basename}'

Get-Content "$HOME\\Desktop\\${link_basename}.lnk" -Encoding Byte | ForEach-Object {
  foreach ( $byte in $_ ) {
    $output += '{0:X2} ' -f $byte
  }
  write-output $output 
}

END_COMMAND
) do
    its(:stdout) { should match /C0 00 00 00 00 00 00 46/ }
  end

```
History
-------

 *  0.1.0 initial release as [Puppet class](https://docs.puppetlabs.com/puppet/latest/reference/lang_classes.html)
 *  0.2.0 rewritten as [Puppet defined type](https://docs.puppetlabs.com/puppet/latest/reference/lang_defined_types.html).
Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)

