#!/bin/sh
pushd /uru
export URU_INVOKER=bash
export GEM_VERSION=2.1.0
export RAKE_VERSION=10.1.0
export RUBY_VERSION=2.1.9
# TODO: prevent gems from installing to ~/.gem/ruby/2.1.0/gems
cat <<EOF>'$HOME/.uru/rubies.json'
{
  "Version": "1.0.0",
  "Rubies": {
  "2357568376": {
    "ID": "2.1.9-p490",
    "TagLabel": "219p490",
    "Exe": "ruby",
    "Home": "/uru/ruby/bin",
    "GemHome": "/uru/ruby/lib/ruby/gems/${GEM_VERSION}/gems",
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
