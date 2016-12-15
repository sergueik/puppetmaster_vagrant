## Uru

### Introduction. Execution

One can bootstrap a standalone ruby environment to run [serverspec](http://serverspec.org/resource_types.html) and generate HTML, XML and json rspec reports.
with the help of [uru](https://bitbucket.org/jonforums/uru/wiki/Usage) on an internet-blocked Windows or Linux instance (uru is not the only option for Linux).

Assuming uru module is added to control repository role / profile, the serverspec run would be triggered locally on the instance by Puppet to verify the 'production' modules.

It is no longer necessary to launch throgh Vagrantfile, though it is still possible - Puppet is likely to skip serverspec from running during incremental runs.

To continue running serverspec through [vagrant-serverspec](https://github.com/jvoorhis/vagrant-serverspec)
plugin, one would have to modify the `Vagrantfile` to include the new location of the `rspec` files inside the module `files`
e.g. assuming that serverspec are platform-specific, and the mapping between instance's Vagrant `config.vm.box` and the `arch` is defined elsewhere:

```ruby
arch = config.vm.box || 'linux'
config.vm.provision :serverspec do |spec|
  if File.exists?("spec/#{arch}")
    spec.pattern = "spec/#{arch}/*_spec.rb"
  elseif File.exists?("files/serverspec/#{arch}")
    spec.pattern = "files/serverspec/#{arch}/*_spec.rb"
  end
end
```
The `uru` module can collect serverspec resources from other modules's via `puppet:///modules` URI and the Puppet [file](https://docs.puppet.com/puppet/latest/reference/type.html#file-attribute-sourceselect) resource:
```puppet
file {'spec/local':
  ensure              => directory,
  path                => "${tool_root}/spec/local",
  recurse             => true,
  source              => $modules.map |$name| {"puppet:///modules/${name}/serverspec/${::osfamily}"},
  source_permissions => ignore,
  sourceselect        => all,
}
```

Alternatively when using [roles and profiles](http://www.craigdunn.org/2012/05/239/)), the `uru` module can collect serverspec files from the profile: `/site/profile/files` which is also accessible via `puppet:///modules` URI.
```puppet
file {'spec/local':
  ensure              => directory,
  path                => "${tool_root}/spec/local",
  recurse             => true,
  source              => $server_roles.map |$server_role| {"puppet:///modules/profile//serverspec/roles/${server_role}" },
  source_permissions => ignore,
  sourceselect       => all,
}
```

This mechanism relies on Puppet [file type](https://github.com/puppetlabs/puppet/blob/cdf9df8a2ab50bfef77f1f9c6b5ca2dfa40f65f7/lib/puppet/type/file.rb)
and its 'sourceselect'  attribute. No equivalent mechanism is implemented with Chef yet.

### Internals
One could provision Uru environment from a zip/tar archive, one can also construct a Puppet module for the same. This is a lightweight alternative to [DracoBlue/puppet-rvm](https://github.com/dracoblue/puppet-rvm) module, which is likely need to build Ruby from source anyway.

The `$URU_HOME` home directory with Ruby runtime plus a handful of gems has the following structure:
```
+---.gem
+---reports
+---ruby
|   +---bin
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
```powershell
uru_rt.exe admin add ruby\bin
uru_rx.exe gem install --no-rdoc --no-ri serverspec rspec rake json rspec_junit_formatter
```
and zip the directory.

On Linux, the tarball creation starts with compiling Ruby from source, configured with a prefix `${URU_HOME}/ruby`:
```bash
export URU_HOME='/uru'
export RUBY_VERSION='2.1.9'
wget https://cache.ruby-lang.org/pub/ruby/2.1/ruby-${RUBY_VERSION}.tar.gz
tar xzvf ruby-${RUBY_VERSION}.tar.gz
yum groupinstall -y 'Developer Tools'
yum install -y zlib-devel openssl-devel libyaml-devel

pushd ruby-${RUBY_VERSION}
./configure --prefix=${URU_HOME}/ruby --disable-install-rdoc --disable-install-doc
make clean
make
sudo make install
```
Next one installs binary distribution of `uru`:
```bash
export URU_HOME='/uru'
export URU_VERSION='0.8.1'
pushd $URU_HOME
wget https://bitbucket.org/jonforums/uru/downloads/uru-${URU_VERSION}-linux-x86.tar.gz
tar xzvf uru-${URU_VERSION}-linux-x86.tar.gz
```
After Ruby and uru is installed one switches to the isolated environment
and installs the required gem dependencies
```bash
./uru_rt admin add ruby/bin
./uru_rt ls
./uru_rt 219p490
./uru_rt gem list
./uru_rt gem install --no-ri --no-rdoc rspec serverspec rake rspec_junit_formatter
cp -R ~/.gem .
```
Finally the `$URU_HOME` is converted to an archive, that can be provisioned on a clean system.

NOTE: with `$GEM_HOME` one can make sure gems are installed under `.gems` rather then the
into a hidden `$HOME/.gem` directory.
This may not work correctly with some releases of `uru`. To verify, run the command on a system `uru` is provisioned from the tarball:
```bash
./uru_rt gem list --local --verbose
```
If the list of gems is shorter than expected, e.g. only the following gems are listed,
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
the `${URU_HOME}\.gem` directory may need to get copied to `${HOME}`

If the error
```ruby
<internal:gem_prelude>:1:in `require': cannot load such file -- rubygems.rb (LoadError)
```
is observed, note that you have to unpackage the archive `uru.tar.gz` into the same `$URU_HOME` path which was configured when Ruby was compiled.
Note: [rvm](http://stackoverflow.com/questions/15282509/how-to-change-rvm-install-location) is known to give the same error if the `.rvm` diredctory location was changed .

In the `spec` directory there is a trimmed down `windows_spec_helper.rb` and `spec_helper.rb` required for `serverspec` gem:
```ruby
require 'serverspec'
set :backend, :cmd
```

and a vanilla `Rakefile` generated by `serverspec init`
```ruby
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
with a formatting option added:
```ruby
t.rspec_opts = "--format documentation --format html --out reports/report_#{$host}.html --format json --out reports/report_#{$host}.json"
```
This would enforce verbose formatting of rspec result [logging](http://stackoverflow.com/questions/8785358/how-to-have-junitformatter-output-for-rspec-run-using-rake).

The `spec/local` directory can contain arbitrary number of domain-specific spec files, as explained above.
The `uru` module contains a basic serverspec file `uru_spec.rb` that serves as a smoke test of the `uru` environment:

Linux:
```ruby
require 'spec_helper'
context 'uru smoke test' do
  context 'basic os' do
    describe port(22) do
        it { should be_listening.with('tcp')  }
    end
  end
  context 'detect uru environment' do
    uru_home = '/uru'
    gem_version='2.1.0'
    user_home = '/root'
    describe command('echo $PATH') do
      its(:stdout) { should match Regexp.new("_U1_:#{user_home}/.gem/ruby/#{gem_version}/bin:#{uru_home}/ruby/bin:_U2_:") }
    end
  end
end
```

Windows:
```ruby
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
    its(:stdout) { should match Regexp.new('_U1_;c:\\\\uru\\\\ruby\\\\bin;_U2_;', Regexp::IGNORECASE) }
  end
end
```
but any domain-specific serverspec files can be placed into the `spec/local` folder.

There should be no nested subdirectories in `spec/local`. If there are subdirectories, their contents will be silently ignored.

Finally in `${URU_HOME}` there is a platform-specific  bootstrap script:

`runner.ps1` for Windows:
```powershell
$URU_HOME = 'c:/uru'
$GEM_VERSION = '2.1.0'
$RAKE_VERSION = '10.1.0'
pushd $URU_HOME
uru_rt.exe admin add ruby\bin
$env:URU_INVOKER = 'powershell'
.\uru_rt.exe ls --verbose
$TAG = (invoke-expression -command 'uru_rt.exe ls') -replace '^\s+\b(\w+)\b.*$', '$1'
.\uru_rt.exe $TAG
.\uru_rt.exe ruby ruby\lib\ruby\gems\${GEM_VERSION}\gems\rake-${RAKE_VERSION}\bin\rake spec
```

`runner.sh` for Linux:
```bash
#!/bin/sh
export URU_HOME=/uru
export GEM_VERSION='2.1.0'
export RAKE_VERSION='10.1.0'

export URU_INVOKER=bash
pushd $URU_HOME
./uru_rt admin add ruby/bin
./uru_rt ls --verbose
export TAG=$(./uru_rt ls 2>& 1|awk -e '{print $1}')
./uru_rt $TAG
./uru_rt gem list
./uru_rt ruby ruby/lib/ruby/gems/${GEM_VERSION}/gems/rake-${RAKE_VERSION}/bin/rake spec
```

The results are nicely formatted in a standalone [HTML report](https://coderwall.com/p/gfmeuw/rspec-test-results-in-html):

![resultt](https://raw.githubusercontent.com/sergueik/puppetmaster_vagrant/master/uru/screenshots/result.png)

and a json:
```javascript
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

One can easily extract the stats by spec file, descriptions of the failed tests and the overall `summary_line` from the json to stdout to get it captured in the console log useful for CI:
```ruby
report_json = File.read('results/report_.json')
report_obj = JSON.parse(report_json)

puts 'Failed tests':
report_obj['examples'].each do |example|
  if example['status'] !~ /passed|pending/i
    pp [example['status'],example['full_description']]
  end
end

stats = {}
result_obj[:examples].each do |example|
  file_path = example[:file_path]
  unless stats.has_key?(file_path)
    stats[file_path] = { :passed => 0, :failed => 0, :pending => 0 }
  end
  stats[file_path][example[:status].to_sym] = stats[file_path][example[:status].to_sym] + 1
end
puts 'Stats:'
stats.each do |file_path,val|
  puts file_path + ' ' + (val[:passed] / (val[:passed] + val[:pending] + val[:failed])).floor.to_s + ' %'
end

puts 'Summary:'
pp result_obj[:summary_line]
```

To execute these one has to involve `uru_rt`.
Linux:
```bash
./uru_rt admin add ruby/bin/ ; ./uru_rt ruby processor.rb --no-warnings --maxcount 100
```

Windows:
```cmd
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy remotesigned  ^
-Command "& {  \$env:URU_INVOKER = 'powershell'; iex -command 'uru_rt.exe admin add ruby/bin/' ; iex -command 'uru_rt.exe ruby processor.rb --no-warnings --maxcount 100'}"
```
Alternatively on Windows one can process the `result.json` in pure Powewrshell:
```powershell
<#
    .SYNOPSIS
    This subroutine processes the serverspec report and prints full description of failed examples.
    Optionally shows pending examples, too.

   .DESCRIPTION
    This subroutine processes the serverspec report and prints description of examples that had not passed. Optionally shows pending examples, too.

    .EXAMPLE
    processor.ps1 -report 'result.json' -directory 'reports'  -serverspec 'spec/local' -warnings -maxcount 10

    .PARAMETER warnings
    switch: specify to print examples with the status 'pending'. By default only the examples with the status 'failed' are printed.
#>
param(
  [Parameter(Mandatory = $false)]
  [string]$name = 'result.json',
  [Parameter(Mandatory = $false)]
  [string]$directory = 'results',
  [Parameter(Mandatory = $false)]
  [string]$serverspec = 'spec\local',
  [int]$maxcount = 100,
  [switch]$warnings
)

$statuses = @('passed')

if ( -not ([bool]$PSBoundParameters['warnings'].IsPresent )) {
  $statuses += 'pending'
}

$statuses_regexp = '(?:' + ( $statuses -join '|' ) +')'

$results_path = ("${directory}/${name}" -replace '/' , '\');
if (-not (Test-Path $results_path)) {
  write-output ('Results is unavailable: "{0}"' -f $results_path )
  exit 0
}
if ($host.Version.Major -gt 2) {
  $results_obj = Get-Content -Path $results_path | ConvertFrom-Json ;
  $count = 0
  foreach ($example in $results_obj.'examples') {
    if ( -not ( $example.'status' -match $statuses_regexp )) {
      # get few non-blank lines of the description
      # e.g. when the failed test is an inline command w/o a wrapping context
      $full_description = $example.'full_description'
      if ($full_description -match '\n|\\n' ){
        $short_Description = ( $full_description -split '\n|\\n' | where-object { $_ -notlike '\s*' } |select-object -first 2 ) -join ' '
      } else {
        $short_Description = $full_description
      }
      Write-Output ("Test : {0}`r`nStatus: {1}" -f $short_Description,($example.'status'))
      $count++;
      if (($maxcount -ne 0) -and ($maxcount -lt $count)) {
        break
      }
    }
  }
  # compute stats -
  # NOTE: there is no outer context information in the `result.json`
  $stats = @{}
  $props =  @{
    Passed = 0
    Failed = 0
    Pending = 0
  }
  foreach ($example in $results_obj.'examples') {
    $spec_path = $example.'file_path'
    if (-not $stats.ContainsKey($spec_path)) {
      $stats.Add($spec_path, (New-Object -TypeName PSObject -Property $props ))
    }
    # Unable to index into an object of type System.Management.Automation.PSObject
    $stats[$spec_path].$($example.'status') ++

  }

  write-output 'Stats:'
  $stats.Keys | ForEach-Object {
    $spec_path = $_
    # extract outermost context from spec:
    $context_line = select-string -pattern @"
context ['"].+['"] do
"@ -path $spec_path | select-object -first 1
    $context = $context_line -replace @"
^.+context\s+['"]([^"']+)['"]\s+do\s*$
"@, '$1'
    # NOTE: single quotes needed in the replacement
    $number_examples = $stats[$spec_path]
    # not counting pending examples
    # $total_number_examples = $number_examples.Passed + $number_examples.Pending + $number_examples.Failed
    $total_number_examples = $number_examples.Passed + $number_examples.Failed
    Write-Output ("{0}`t{1}%`t{2}" -f ( $spec_path -replace '^.+[\\/]','' ),([math]::round(100.00 * $number_examples.Passed / $total_number_examples,2)), $context)
  }
  write-output 'Summary:'
  Write-Output ($results_obj.'summary_line')
} else {
  Write-Output (((Get-Content -Path $results_path) -replace '.+\"summary_line\"' , 'serverspec result: ' ) -replace '}', '' )
}
```

For convenience the `processor.ps1` and `processor.rb` are provided. Finding and converting to a better structured HTML report layout with the help of additional gems is a work in progress.

The Puppet module is available in a sibling directory:
 * [exec_uru.pp](https://github.com/sergueik/puppetmaster_vagrant/blob/master/modules/custom_command/manifests/exec_uru.pp)
 * [uru_runner_ps1.erb](https://github.com/sergueik/puppetmaster_vagrant/blob/master/modules/custom_command/templates/uru_runner_ps1.erb)

### Migration
To migrate serverspec from a the [vagrant-serverspec](https://github.com/jvoorhis/vagrant-serverspec) default directory, one may use
`require_relative`. Also pay attention to use a conditional
```ruby
if File.exists?( 'spec/windows_spec_helper.rb')
  require_relative '../windows_spec_helper'
end
```
in the serverspec in the Ruby sandbox if the same rspec test is about to be run from Vagrant and from the instance

### Useful modifiers

#### To detect Vagrant run :
```ruby
user_home = ENV.has_key?('VAGRANT_EXECUTABLE') ? 'c:/users/vagrant' : ( 'c:/users/' + ENV['USER'] )
```
This will assign a hard coded user name versus target instance environment value to Ruby variable.
Note:  `ENV['HOME']` was not used - it is defined in both cygwin (`C:\cygwin\home\vagrant`)
and Windows environments (`C:\users\vagrant`)

#### To detect URU runtime:
```ruby
context 'URU_INVOKER environment variable', :if => ENV.has_key?('URU_INVOKER')  do
  describe command(<<-EOF
   pushd env:
   dir 'URU_INVOKER' | format-list
   popd
    EOF
  ) do
    its(:stdout) { should match /powershell|bash/i }
  end
end
```

As usual, one can provide custom types in the spec/type directory - that directory is excluded from the spec run.
For example one can define the following class `property_file.rb` to inspect property files:
```ruby
require 'serverspec'
require 'serverspec/type/base'
module Serverspec::Type
  class PropertyFile < Base

    def initialize(name)
      @name = name
      @runner = Specinfra::Runner
    end

    def has_property?(propertyName, propertyValue)
      properties = {}
      IO.foreach(@name) do |line|
        if (!line.start_with?('#'))
          properties[$1.strip] = $2 if line =~ /^([^=]*)=(?: *)(.*)/
        end
      end
      properties[propertyName] == propertyValue
    end
  end

  def property_file(name)
    PropertyFile.new(name)
  end
end

include Serverspec::Type
```
and create the test
```ruby
require 'type/property_file'
context 'Custom Type' do
  property_file_path = "#{user_home}/sample.properties"
  describe property_file(property_file_path) do
    it { should have_property('package.class.property', 'value' ) }
  end
end
```
### Note
The RSpec `format` [options](https://relishapp.com/rspec/rspec-core/docs/command-line/format-option) provided in the `Rakefile`
```ruby
t.rspec_opts = "--require spec_helper --format documentation --format html --out reports/report_#{$host}.html --format json --out reports/report_#{$host}.json"
```
are not compatible with [Vagrant serverspc plugin](https://github.com/jvoorhis/vagrant-serverspec), leading to the following error:
```ruby
The
serverspec provisioner:
* The following settings shouldn't exist: rspec_opts
```
### See Also

 * [cucumberjs-junitxml](https://github.com/sonyschan/cucumberjs-junitxml)
 * [danger-junit Junit XML to HTML convertor](https://github.com/orta/danger-junit)
 * [automating serversped](http://annaken.blogspot.com/2015/07/automated-serverspec-logstash-kibana-part2.html)
 * [loading spec](http://stackoverflow.com/questions/5061179/how-to-load-a-spec-helper-rb-automatically-in-rspec-2)
 * [enable checkboxes in the html-formatted report generated by rspec-core](https://github.com/rspec/rspec-core) and [rspec_junit_formatter](https://github.com/sj26/rspec_junit_formatter) rendered in Interner Explorer, make sure to confirm ActiveX popup. If this does not work, one may have to apply a patch explained in [how  IE generates the onchange event](http://krijnhoetmer.nl/stuff/javascript/checkbox-onchange/) and run the `apply_filters()`  on `onclick`  instead of `onchange`.
 * [filtering RSpec log](https://www.relishapp.com/rspec/rspec-core/docs/configuration/excluding-lines-from-the-backtrace)

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
