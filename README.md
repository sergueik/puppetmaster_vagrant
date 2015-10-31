Introduction
------------
Vagrant and Puppet resources for setting up a box in Virtual Box with Chef and Puppet provisioner and experiement with Serverspec and Puppet Modules


Environment
-----------
Boxes are [cached](http://stackoverflow.com/questions/28399324/download-vagrant-box-file-locally-from-atlas-and-configuring-it) locally in `Downloads` directory. Based on the `BOX_NAME` environment the following guest is created 


| Image tag        | Filename           | Origin  |
| :------------- |:-------------| :-----|
| centos65_i386  | centos_6-5_i386.box                            |  |
| centos66_x64   | centos-6.6-x86_64.box                          |   https://github.com/tommy-muehle/puppet-vagrant-boxes/releases/download/1.0.0/centos-6.6-x86_64.box |
| centos65_x64   | centos-6.5-x86_64.box                          |    |
| centos7        | centos-7.0-x86_64.box                          |  | 
|trusty32        | trusty-server-cloudimg-i386-vagrant-disk1.box  |  |
|trusty64        | trusty-server-cloudimg-amd64-vagrant-disk1.box | |
|precise64       | ubuntu-server-12042-x64-vbox4210.box           | |
|windows_xp      | IE8.XP.For.Vagrant.box | (https://atlas.hashicorp.com/opentable/boxes/win-2008r2-standard-amd64-nocm/versions/1.0.1/providers/virtualbox.box)|
|windows_2008    | windows-2008R2-serverstandard-amd64_virtualbox.box| (https://atlas.hashicorp.com/opentable/boxes/win-2008r2-standard-amd64-nocm/versions/1.0.1/providers/virtualbox.box)|
|windows_2012    | windows_2012_r2_standard.box | (https://atlas.hashicorp.com/kensykora/boxes/windows_2012_r2_standard/versions/0.7.0/providers )|
|windows7 | vagrant-win7-ie10-updated.box |  |

All box definitions are stored in `Vagrantfile.local`. Uncomment the desired box and comment the rest:
```
# windows 7
  box_name = 'windows7'
  box_memory = 1024
  box_cpus = 1
  box_gui = true
```
All versions of the Linux box of the same distribution are named like `centos`, `ubuntu` do to switch between the versions make sure to recycle `~/.vagrant.d/boxes/<brand>`. Windows boxes are named differently.

WinRM
-----
Tweaking of modern.ie image into a vagrant manageable box is covered e.g. in
[uchagani/Vagrant-Windows.md](https://gist.github.com/uchagani/48d25871e7f306f1f8af) and
[Setup a Windows 7 box](https://groups.google.com/forum/#!topic/vagrant-up/PpRelVs95tM)

Puppet
------
Most Linux boxes have Puppet 3.8.x . The Windows ones do not. To install Puppet, set `config_vm_newbox` to `true` only when importing brand new Windos box image. To save provisioning time, set `config_vm_newbox` to `false`. Vagrantfile uses shell provisioner to install latest Puppet.

ServerSpec
----------
Currently most development targets Windows guests (Linux servesrpec is well covered elsewhere). 

  - Command Execution
  - GAC Assembly loadfing / assertion
  - ReparsePoint (Symlink and Directory Junction) validation
  - Loading Nunt.Core for adding Asserts into the Powershell snippets

Notes
-----
* Some of the configuration ported from [Building a Test Puppet Master With Vagrant](http://grahamgilbert.com/blog/2013/02/13/building-a-test-puppet-master-with-vagrant/) . 
* See also [A modern Puppet Master from scratch](http://stdout.no/a-modern-puppet-master-from-scratch/)
* [Provisioning a Windows box with Vagrant, Chocolatey and Puppet](www.tzehon.com/2014/01/20/provisioning-a-windows-box-with-vagrant-chocolatey-and-puppet-part-1/)
* [Vagrant Boxes for playing with Puppet on Windows (but not boxes...](https://github.com/ferventcoder/vagrant-windows-puppet) specifically for DSC
