Info
----

With the help of [uru](https://bitbucket.org/jonforums/uru/wiki/Usage) one can bootstrap  a standalone ruby environment on windows platform. One could compose a zip with Ruby runtime plus a handful of gems on and explore it on the target instance. Next one would construct a Puppet module for the same.
The uru directory has the following structure:
```

+---reports
+---ruby
|   +---bin
|   +---include
|   |   +---ruby-2.1.0
|   |       +---ruby
|   |       |   +---backward
|   |       +---x64-mingw32
|   |           +---ruby
|   +---lib
|   |   +---pkgconfig
|   |   +---ruby
|   |       +---2.1.0
|   |       +---gems
|   |       |   +---2.1.0
|   |       |       +---cache
|   |       |       +---gems
|   |       |       +---specifications
|   |       |           +---default
|   |       +---site_ruby
|   |           +---2.1.0
|   +---share
|       +---man
|           +---man1
+---spec
    +---local
```
![uru folder](https://raw.githubusercontent.com/sergueik/puppetmaster_vagrant/master/uru/uru.png)

The directory contains a trimmed down 'windows_spec_helper.rb':
```
require 'serverspec'
set :backend, :cmd
```

and a stock Rakefile with just one modification:
```
  t.rspec_opts = "--format documentation \
--format html --out reports/report_#{$host}.html \
 --format json --out reports/report_#{$host}.json"
```
to enforce file logging. The `local` directory can contain arbitrary number of spec files, and a bootstrapper script which basically calls
```
pushd c:/uru
uru_rt.exe admin add ruby\bin
uru_rt.exe ruby ${RubyPath}\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake spec
```

The `uru` module contains a basic serverspec  file that is run as a smoke test, but any real serverspec files can be dropped into the `local` folder and will run automatically.  Few real serverspec files from existing LP modules have been put to the instance and run successfully.


The results are nicely formatted in a standalone report:

![resultt](https://raw.githubusercontent.com/sergueik/puppetmaster_vagrant/master/uru/result.png)


One still has to implement some tool to parse the json and determine what happened. 
I guess it may deserve some special handling better than printing to std out but i do not have anything



