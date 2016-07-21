#!/bin/sh
pushd /uru
export URU_HOME=`pwd`
export URU_INVOKER=bash
export GEM_VERSION=2.1.0
export RAKE_VERSION=10.1.0
export RUBY_VERSION=2.1.9
export LD_LIBRARY_PATH=${URU_HOME}/ruby/lib
# TODO: prevent gems from installing to ~/.gem/ruby/2.1.0/gems
cat <<EOF>'$HOME/.uru/rubies.json'
{
  "Version": "1.0.0",
  "Rubies": {
  "2357568376": {
    "ID": "2.1.9-p490",
    "TagLabel": "219p490",
    "Exe": "ruby",
    "Home": "${URU_HOME}/ruby/bin",
    "GemHome": "${URU_HOME}/.gem/ruby/${GEM_VERSION}",
    "Description": "ruby 2.1.9p490 (2016-03-30 revision 54437) [x86_64-linux]"
    }
 }
}
EOF


# TODO: remove uru/ruby/lib/ruby/gems/2.1.0/gems/gems/
./uru_rt admin add ruby/bin

TAG=$(./uru_rt  ls 2>& 1|awk -e '{print $1}')
./uru_rt $TAG
./uru_rt ls --verbose
./uru_rt gem list
./uru_rt ruby ruby/lib/ruby/gems/${GEM_VERSION}/gems/rake-${RAKE_VERSION}/bin/rake spec


# Process the results

./uru_rt ruby <<EOF
require 'json'
require 'pp'
REPORT='reports/report_.json'
report = File.open(REPORT)
z = JSON.parse(report.read, symbolize_names: true)
pp z[:summary_line]
EOF
