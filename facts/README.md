Info
----
Reusable Puppet facts. Skeleton Ruby script to test the facter code snippets on Windows target is provided.
```
PATH=%PATH%;"c:\Program Files\Puppet Labs\Puppet\sys\ruby\bin"
ruby fact_wrapper.rb
sample fact value
```

Note
----
Windows facts are returned by running the appropriate WMI query and in general  facter role is often reduced to dispatching the fact derivatinon to `WMI`, `Powershell`, `netsh` and similar utilities which have their own metadata schemas

See also
--------
 * [adenning](https://github.com/adenning/winfacts)
 * [kwilczynski](https://github.com/kwilczynski/facter-facts)
 * [mstanislav](https://github.com/mstanislav/Facter-Plugins)
 * [jantman](https://github.com/jantman/puppet-facter-facts)
 * [mcanevet](https://github.com/mcanevet/rspec-puppet-facts)
