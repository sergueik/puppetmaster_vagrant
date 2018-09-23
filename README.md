### Introduction
Vagrant and Puppet resources for setting up a box in Virtual Box with Chef and Puppet provisioner and experiement with Serverspec and Puppet Modules




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

Examples of various non-elemenatary cases on Windows and Linux guests using OS-provided 
and Puppet provided tools ( augeas ) for application conguration expectations. 
Many of the developed expectations can and are converred into Puppet facts to use 
e.g. in situtions core Puppet has trouble executing the update scenarios.

On Windows this includes:
```shell

acl_spec.rb                     mixed_spec.rb
apache_conf_file_spec.rb        multiversion_spec.rb
basic_commands_spec.rb          named_pipe_spec.rb
binary_type.rb                  ndp_spec.rb
bool_spec.rb                    netstat_spec.rb
broken_encoding_spec.rb         parameter_spec.rb
cert_thumbprint_spec.rb         path_spec.rb
chunked_spec.rb                 pending_reboot_spec.rb
command_stdout_as_json_spec.rb  port_listening_with_retry_monkey_patch_spec.rb
command_stdout_as_yaml_spec.rb  port_retry_spec.rb
commandline_fix_spec.rb         ports_spec.rb
crc32_spec.rb                   process_owner_spec.rb
credential_provider_spec.rb     process_spec.rb
credentials_spec.rb             property_file_spec.rb
desktop_size_spec.rb            puppet_helper.rb
directory_spec.rb               puppet_lastrun_report_spec.rb
domain_spec.rb                  quasi_random_config_spec.rb
encoded_command_spec.rb         registry_spec.rb
environment_spec.rb             report_print_spec.rb
eventlog_query.ps1              rexml_spec.rb
eventlog_query.ps1.SAVED        ruby_exec_with_env_spec.rb
eventlog_spec.rb                ruby_exec_with_helper_spec.rb
eventlog_type_spec.rb           ruby_exec_with_loadpath_spec.rb
external_assembly_spec.rb       ruby_powershell_spec.rb
facter_spec.rb                  run_report_helpper_spec.rb
file_checksum_spec.rb           run_report_puppet_helper_spec.rb
fileversion_spec.rb             scheduled_task_raw_spec.rb
find_assembly_spec.rb           servicemodel_spec.rb
firewall_spec.rb                services_spec.rb
framework_spec.rb               servicetype_spec.rb
gac_tests_spec.rb               shares_spec.rb
gcr.ps1                         shortcut_spec.rb
groovy_spec.rb                  site_spec.rb
group_member_spec.rb            size_problem_spec.rb
group_member2_spec.rb           skeleton_puppet_enterprise_script_spec.rb
growl_spec.rb                   snarl_spec.rb
hotfix_spec.rb                  symlink_spec.rb
http_get_spec.rb                test.rb
hypervisor_driver_spec.rb       test_with_initial_delay_spec.rb
iis_apppool_spec.rb             timezone_spec.rb
iis_configuration_spec.rb       uac_spec.rb
installer_key_spec.rb           uptime_spec.rb
java_run_spec.rb                uru_spec.rb
jdbc_spec.rb                    utf8_spec.rb
jira_reporting_spec.rb          version_spec.rb
last_run_report_spec.rb         vmware_spec.rb
last_run_report_uru_spec.rb     windowsfeature_spec.rb
licensestatus_spec.rb           xml_spec.rb
mac_address_spec.rb

```
  - Command Execution
  - GAC Assembly loadfing / assertion
  - ReparsePoint (Symlink and Directory Junction) validation
  - Loading Nunt.Core for adding Asserts into the Powershell snippets

On Linux this includes:
```shell

activemq_spec.rb              openssl_client_spec.rb
apache_conf_spec.rb           orphaned_files_spec.rb
app_remote_port_spec.rb       package_gem_provider_spec.rb
augeas_exec_spec.rb           pgrep_spec.rb
consul_extended_spec.rb       port_retry_spec.rb
consul_spec.rb                postfix_spec.rb
context.xml                   puppet_run_spec.rb
cron_custom_spec.rb           remote_port_spec.rb
cron_spec.rb                  retry_command_spec.rb
dns_spec.rb                   rexml_spec.rb
empty_dir_Spec.rb             ruby_spec.rb
http_get_spec.rb              run_report_puppet_helper_spec.rb
http_get_unit_spec.rb         sample_puppet_lastrun_report_spec.rb
jdbc_spec.rb                  sample_spec.rb
jenkins_project_spec.rb       semi_random_assignment_spec.rb
jenkins_project2_spec.rb      server.xml
jenkins_spec.rb               service_restart_event__spec.rb
jq_spec.rb                    shared_examples_spec.rb
limits_spec.rb                shell_script_contents_spec.rb
log_glob_spec.rb              timeout_socket_spec.rb
logstash_spec.rb              timezone_spec.rb
mongodb_basic_spec.rb         tomcat_rotated_log_spec.rb
mongodb_replset_java_spec.rb  udeploy_spec.rb
mongodb_replset_spec.rb       valid_symlink_spec.rb
multi_run_report.rb           vhosts_spec.rb
mysql_basic_spec.rb           vmware_spec.rb
named_pipe_spec.rb            xmllint_spec.rb
npm_modules_spec.rb


```
Environment
-----------
Boxes are [cached](http://stackoverflow.com/questions/28399324/download-vagrant-box-file-locally-from-atlas-and-configuring-it) locally in `Downloads` directory. Based on the `BOX_NAME` environment the following guest is created 


| Image tag        | Filename           | Origin  |
| :------------- |:-------------| :-----|
| centos65_i386  | centos_6-5_i386.box                            |  |
| centos66_x64   | centos-6.6-x86_64.box                          |   https://github.com/tommy-muehle/puppet-vagrant-boxes/releases/download/1.0.0/centos-6.6-x86_64.box |
| centos65_x64   | centos-6.5-x86_64.box                          |    |
| centos67_x64   | vagrant-centos-6.7.box                         |Puppet 4.3|
| centos7        | centos-7.0-x86_64.box                          |  | 
| centos71       | vagrant-centos-7.1.box                         |Puppet 4.3| 
|trusty32        | trusty-server-cloudimg-i386-vagrant-disk1.box  |  |
|trusty64        | trusty-server-cloudimg-amd64-vagrant-disk1.box | |
|precise64       | ubuntu-server-12042-x64-vbox4210.box           | |
|windows_xp      | IE8.XP.For.Vagrant.box | (https://atlas.hashicorp.com/opentable/boxes/win-2008r2-standard-amd64-nocm/versions/1.0.1/providers/virtualbox.box)|
|windows_2008    | windows-2008R2-serverstandard-amd64_virtualbox.box| (https://atlas.hashicorp.com/opentable/boxes/win-2008r2-standard-amd64-nocm/versions/1.0.1/providers/virtualbox.box)|
|windows_2012    | windows_2012_r2_standard.box | (https://atlas.hashicorp.com/kensykora/boxes/windows_2012_r2_standard/versions/0.7.0/providers )|
|windows7 | vagrant-win7-ie10-updated.box |  |

These images are made  availablei on [Microsoft Edge Team Dev site](https://dev.windows.com/en-us/microsoft-edge/tools/vms/windows/).

Notes
-----
* Some of the configuration ported from [Building a Test Puppet Master With Vagrant](http://grahamgilbert.com/blog/2013/02/13/building-a-test-puppet-master-with-vagrant/) . 
* See also [A modern Puppet Master from scratch](http://stdout.no/a-modern-puppet-master-from-scratch/)
* [Provisioning a Windows box with Vagrant, Chocolatey and Puppet](www.tzehon.com/2014/01/20/provisioning-a-windows-box-with-vagrant-chocolatey-and-puppet-part-1/)
* [Vagrant Boxes for playing with Puppet on Windows (but not boxes...](https://github.com/ferventcoder/vagrant-windows-puppet) specifically for DSC

* branch puppet_43 contains file and directory changes required to provision the vm via Puppet 4.3
* See also [basic demo of using Serverspec to test Puppet](https://github.com/woodie00101/example_puppet-serverspec), with hiera.
* see also [another basic Puppet Vagrant Serverspec integration project](https://github.com/andrewwardrobe/PuppetIntegration)

### License
This project is licensed under the terms of the MIT license.

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
