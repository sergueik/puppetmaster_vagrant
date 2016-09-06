
## Uruu

### Introduction. Execution

One can bootstrap a standalone ruby environment to run [serverspec](http://serverspec.org/resource_types.html).
with the help of [uru](https://bitbucket.org/jonforums/uru/wiki/Usage) on an internet-blocked Windows or Linux instance (uru is not the only option for Linux).

One could provision Uru environment from a zip/tar archive, one can also construct a Puppet module for the same. This is lightweight alternative to [DracoBlue/puppet-rvm](https://github.com/dracoblue/puppet-rvm) module.

Assuming uru module is added to control repository role / profile, the serverspec run would be triggered locally on the instance by Puppet to verify the 'production' modules.

These are no longer necessary to launch throgh Vagrantfile, though it is still possible - Puppet is likely to skip serverspec from running during incremental runs.

To continue running serverspec through [vagrant-serverspec](https://github.com/jvoorhis/vagrant-serverspec) 
plugin, one has to modify the `pattern` block in `Vagrantfile` to point the plugin to the `serverspec` directory within the module (assuming the serverspec are platform-specific):

```
  config.vm.provision :serverspec do |spec|
    $arch = 'linux'
    if File.exists?("spec/#{arch}")
      spec.pattern = "spec/#{arch}/*_spec.rb"
    elseif File.exists?("files/serverspec/#{arch}")
      spec.pattern = "files/serverspec/#{arch}/*_spec.rb"
    end
  end
```

### Internals
The `$URU_HOME` home directory with Ruby runtime plus a handful of gems has the following structure:
```

+---.gem
+---reports
+---ruby
|   +---bin
...
+---spec
    +---local
```
![uru folder](https://raw.githubusercontent.com/sergueik/puppetmaster_vagrant/master/uru/screenshots/uru.png)

It has the following  gems and their dependencies installed:
```
rake
rspec
rspec_junit_formatter
serverspec
```


### Setup
For windows, `uru.zip` can be created by copying `uru` and [Ruby] runtime installed from an [MSI](http://rubyinstaller.org/downloads/) on a instance with internet access, for example, on a developer host, the `$URU_HOME` folder
and install all dependency gems from a sandbox Ruby instance:
```
uru_rt.exe admin add ruby\bin
uru_rx.exe gem install --no-rdoc --no-ri serverspec rspec rake json rspec_junit_formatter
```
and zip the directory.

On Linux, the tarball creation starts with compiling Ruby from source , with a prefix `${URU_HOME}/ruby`:
```
wget https://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.9.tar.gz
tar xzvf ruby-2.1.9.tar.gz
yum groupinstall -y 'Developer Tools'
yum install -y zlib-devel openssl-devel libyaml-devel
pushd ruby-2.1.9
./configure --prefix=/uru/ruby --disable-install-rdoc --disable-install-doc
make clean
make
sudo make install
```
After Ruby is installed one switches to the isolated environment
```
pushd $URU_HOME
wget https://bitbucket.org/jonforums/uru/downloads/uru-0.8.1-linux-x86.tar.gz
tar xzvf uru-0.8.1-linux-x86.tar.gz
./uru_rt admin add ruby/bin
./uru_rt ls
./uru_rt 219p490
```
and installs the required gem dependencies
```
./uru_rt gem list
./uru_rt gem install --no-ri --no-rdoc rspec serverspec rake rspec_junit_formatter
cp -R ~/.gem .
```
Finally the `$URU_HOME` is converted to an archive, that can be installed on a clean system.

With `$GEM_HOME` one can make sure gems are installed under `.gems` rather then the
into a hidden `$HOME/.gem` directory. 
This may not work correctly, if there was an error. 
To verify, run the command
```
./uru_rt gem list --local --verbose
```
If the list of gems is different than expected, e.g. only the following gems are listed,
```
bigdecimal (1.2.4)
io-console (0.4.3)
json (1.8.1)
minitest (4.7.5)
psych (2.0.5)
rake (10.1.0)
rdoc (4.1.0)
test-unit (2.1.10.0)
```
copy the `.gem` directory into `$HOME`.

If the error
```
<internal:gem_prelude>:1:in `require': cannot load such file -- rubygems.rb (LoadError)

```
is returned, you have to use the expand the `uru.tar.gz` archive into the same path `$URU_HOME` which was specified when Ruby was compiled. Note: [rvm](http://stackoverflow.com/questions/15282509/how-to-change-rvm-install-location) is known to give the same error if the `.rvm` diredctory location was changed .

In the `spec` directory one places a trimmed down `windows_spec_helper.rb` and `spec_helper.rb`:
```
require 'serverspec'
set :backend, :cmd
```

and a stock Rakefile
```
require 'rake'
require 'rspec/core/rake_task'

task :spec    => 'spec:all'
task :default => :spec

namespace :spec do
  targets = []
  Dir.glob('./spec/*').each do |dir|
    next unless File.directory?(dir)
    target = File.basename(dir)
    target = "_#{target}" if target == 'default'
    targets << target
  end

  task :all     => targets
  task :default => :all

  targets.each do |target|
    original_target = target == '_default' ? target[1..-1] : target
    desc "Run serverspec tests to #{original_target}"
    RSpec::Core::RakeTask.new(target.to_sym) do |t|
      ENV['TARGET_HOST'] = original_target
      t.rspec_opts = "--format documentation --format html --out reports/report_#{$host}.html --format json --out reports/report_#{$host}.json"
      t.pattern = "spec/#{original_target}/*_spec.rb"
    end
  end
end

```
that is generated by `serverspec init` with formatting option added:
```
t.rspec_opts = "--format documentation --format html --out reports/report_#{$host}.html --format json --out reports/report_#{$host}.json"
```
This would enforce verbose formatting of rspec result [logging](http://stackoverflow.com/questions/8785358/how-to-have-junitformatter-output-for-rspec-run-using-rake).

The `local` directory can contain arbitrary number of domain-specific spec files, and a bootstrapper script which basically calls

on Windows
```
pushd c:/uru
uru_rt.exe admin add ruby\bin
$env:URU_INVOKER = 'powershell'
uru_rt.exe ls
uru_rt.exe $tag
uru_rt.exe ruby ${RubyPath}\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake spec
```


on Linux
```
#!/bin/sh
export URU_INVOKER=bash
pushd /uru
./uru_rt admin add ruby/bin
./uru_rt ls --verbose
TAG=$(./uru_rt  ls 2>& 1|awk -e '{print $1}')
./uru_rt $TAG
./uru_rt gem list
./uru_rt ruby ruby/lib/ruby/gems/2.1.0/gems/rake-10.1.0/bin/rake spec
```
The `uru` module contains a basic sample serverspec file that is run as a smoke test, but any real serverspec files can be dropped into the `local` folder and will run automatically.  During testing of the module, a number real serverspec files from existing LP modules have been put to the `uru` directory and run without errors.
All spec files should be put in the same directory, e.g. `spec\localhost`
```
require 'spec_helper'
context 'basic tests' do
  describe port(3389) do
    it do
     should be_listening.with('tcp')
     should be_listening.with('udp')
    end
  end

  describe file('c:/windows') do
    it { should be_directory }
  end
end
context 'detect uru environment through a custom PATH prefix' do
  describe command(<<-EOF
   pushd env:
   dir 'PATH' | format-list
   popd
    EOF
  ) do
    # will fail as long as the .gems are put under $HOME
    its(:stdout) { should match Regexp.new('_U1_;c:\\\\uru\\\\ruby\\\\bin;_U2_;', Regexp::IGNORECASE) }
  end
end 
```

The results are nicely formatted in a standalone HTML report:

![resultt](https://raw.githubusercontent.com/sergueik/puppetmaster_vagrant/master/uru/screenshots/result.png)

and json:
```
{
    "version": "3.5.0.beta4",
    "examples": [{
        "description": "should be directory",
        "full_description": "File \"c:/windows\" should be directory",
        "status": "passed",
        "file_path": "./spec/local/windows_spec.rb",
        "line_number": 4,
        "run_time": 0.470411,
        "pending_message": null
    }, {
        "description": "should be file",
        "full_description": "File \"c:/test\" should be file",
        "status": "failed",
        "file_path": "./spec/local/windows_spec.rb",
        "line_number": 8,
        "run_time": 0.545683,
        "pending_message": null,
        "exception": {
            "class": "RSpec::Expectations::ExpectationNotMetError",
            ...
        }
    }],
    "summary": {
        "duration": 1.054691,
        "example_count": 2,
        "failure_count": 1,
        "pending_count": 0
    },
    "summary_line": "2 examples, 1 failure"
}
```

One can easily parse the json and extract the `full_description` of failed tests and the  `summary_line`:
```
report_json = File.read('report_.json')
report_obj = JSON.parse(report_json)
report_obj['examples'].each do |example|
  if example['status'] !~ /passed|pending/i
    pp [example['status'],example['full_description']]
  end
end
```
to console so it is captured in provision log.

### Note
To view the html-formatted report generated by [rspec-core](https://github.com/rspec/rspec-core) and [rspec_junit_formatter](https://github.com/sj26/rspec_junit_formatter) has `display-filters` 
in Interner Explorer, make sure to confirm ActiveX popup. If this does not work, one may have to apply a patch epxlained in [how  IE generates the onchange event](http://krijnhoetmer.nl/stuff/javascript/checkbox-onchange/)i  and run the `apply_filters()`  on `onclick`  instead of `onchange`.

See also [cucumberjs-junitxml](https://github.com/sonyschan/cucumberjs-junitxml)

The module can access other modules's serverspec resources via `puppet:///modules` URI:

```
file {'spec/local': 
  ensure             => directory,
  path               => "${tool_root}/spec/local",
  recurse            => true,
  source             => $modules.map |$name| {"puppet:///modules/${name}/serverspec/${::osfamily}"},
  source_permissions => ignore,,
  sourceselect       => all,
}
```

Alternatively (when using [roles and profiles](http://www.craigdunn.org/2012/05/239/)) module can collect serverspec files from the profile: `/site/profile/files` is also accessible via `puppet:///modules` URI.
```
file {'spec/local': 
  ensure             => directory,
  path               => "${tool_root}/spec/local",
  recurse            => true,
  source             => $server_roles.map |$server_role| {"puppet:///modules/profile//serverspec/roles/${server_role}" },
  source_permissions => ignore,,
  sourceselect       => all,
}
```

Full module is also available in a sibling directory: 
 * [exec_uru.pp](https://github.com/sergueik/puppetmaster_vagrant/blob/master/modules/custom_command/manifests/exec_uru.pp)
 * [uru_runner_ps1.erb](https://github.com/sergueik/puppetmaster_vagrant/blob/master/modules/custom_command/templates/uru_runner_ps1.erb)

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
