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
![uru folder](https://raw.githubusercontent.com/sergueik/puppetmaster_vagrant/master/uru/screenshots/uru.png)

The list of installed gems is:
```
bigdecimal 
builder 
diff-lcs 
ffi 
gssapi 
gyoku 
httpclient 
io-console 
json 
little-plugger 
logging 
minitest 
multi_json 
net-scp 
net-ssh 
net-telnet 
nori 
psych 
rake 
rdoc 
rspec 
rspec-core 
rspec-expectations 
rspec-its 
rspec-mocks 
rspec-support 
rubyntlm 
serverspec 
sfl 
specinfra 
test-unit 
winrm 
```

The `uru.zip` can be created by installing `uru` on a machine with internet access, for example, on a developer host, copying the home directory of a Ruby installation into the `uru` folder and
and running `uru.bat gem install` there, then packing the directory. This process is similar to deploying the `.rvm` directory via tarball.

The `spec` directory contains a trimmed down 'windows_spec_helper.rb' and `spec_helper.rb` both of which contain:
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
to enforce verbose file logging. 

The `local` directory can contain arbitrary number of spec files, and a bootstrapper script which basically calls
```
pushd c:/uru
uru_rt.exe admin add ruby\bin
uru_rt.exe ruby ${RubyPath}\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake spec
```

The `uru` module contains a basic sample serverspec file that is run as a smoke test, but any real serverspec files can be dropped into the `local` folder and will run automatically.  Few real serverspec files from existing LP modules have been put to the instance and run successfully.
All spec files should be put in the same directory, e.g. `spec\localhost`
```
require 'spec_helper'

describe port(3389) do
  it do 
   should be_listening.with('tcp') 
   should be_listening.with('udp') 
  end
end


describe file('c:/windows') do
  it { should be_directory }
end
```

The results are nicely formatted in a standalone HTML report:

![resultt](https://raw.githubusercontent.com/sergueik/puppetmaster_vagrant/master/uru/screenshots/result.png)

and json:
```
{
    "version": "3.5.0.beta3",
    "examples": [{
        "description": "should be listening with udp",
        "full_description": "Port \"3389\" should be listening with udp",
        "status": "passed",
        "file_path": "./spec/localhost/sample_spec.rb",
        "line_number": 4,
        "run_time": 0.390625,
        "pending_message": null
    }, {
        "description": "should be listening with tcp",
        "full_description": "Port \"3389\" should be listening with tcp",
        "status": "passed",
        "file_path": "./spec/localhost/sample_spec.rb",
        "line_number": 5,
        "run_time": 0.439453,
        "pending_message": null
    }, {
        "description": "should be directory",
        "full_description": "File \"c:/windows\" should be directory",
        "status": "passed",
        "file_path": "./spec/localhost/sample_spec.rb",
        "line_number": 10,
        "run_time": 0.328125,
        "pending_message": null
    }],
    "summary": {
        "duration": 1.18164,
        "example_count": 3,
        "failure_count": 0,
        "pending_count": 0
    },
    "summary_line": "3 examples, 0 failures"
}
```

One still has to implement some tool to parse the json and determine what happened.
I guess the serverspec report may deserve some special handling better than printing to stdout. 
It is  work in progress.


Author
------
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
