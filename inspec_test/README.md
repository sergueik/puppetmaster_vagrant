### Info


This directory contains a replica of [skeleton chef inspec project](https://github.com/jeremymv2/test-inspec) 
updated with `Vagrantfile` placed in the default directory:
```
.kitchen/kitchen-vagrant/default-centos-67/Vagranfile
```

Inlike Vagrant / Puppet /Serverspec combination, this requires also installing ChefDK, and a numner of prerequisite gems:

Then one may run the 
```cmd
kitchen destroy  default-centos-67
kitchen converge default-ubuntu-trusty
kitehcn verify default-ubuntu-trusty
```

This will create tempoarty files and directories
```sh
.kitchen/default-centos-67.yml
.kitchen/kitchen-vagrant/default-centos-67/Vagrantfile
```

### See also

  * [original documentaion](https://learn.chef.io/modules/tdd-with-inspec/rhel/virtualbox#/)
  * [core inspec usage documentation](https://www.diycode.cc/projects/chef/inspec)
  * [blog on scaffolding chef envionment in internet-disconnected machine](https://github.com/jeremymv2/chef-intranet-scaffolding) 
  * [configuting the chef kitchen](https://docs.chef.io/config_yml_kitchen.html)
  * [serverspe versus inspec](https://medium.com/@Joachim8675309/serverspec-vs-inspec-17272df2718f)

