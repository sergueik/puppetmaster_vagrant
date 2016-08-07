#!/bin/sh

export URU_HOME='/uru'
export URU_INVOKER=bash
export GEM_VERSION=2.1.0
export RAKE_VERSION=10.1.0
export RUBY_VERSION=2.1.0

export LD_LIBRARY_PATH=${URU_HOME}/ruby/lib
export URU_RUNNER="${URU_HOME}/uru_rt"
pushd ${URU_HOME}
# TODO: $URU_RUNNER admin refresh
# if the  ~/.uru/rubies.json is different, in particular the GemHome

export HOME='/root'
mkdir $HOME/.uru
rm "$HOME/.uru/rubies.json"
cat <<EOF>"$HOME/.uru/rubies.json"
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

echo Y |$URU_RUNNER  admin rm  219p490 > /dev/null 
$URU_RUNNER admin add ruby/bin

$URU_RUNNER ls --verbose
export TAG=`$URU_RUNNER ls 2>& 1|awk '{print $1}'`
$URU_RUNNER $TAG

# TODO: fix it properly
# Copy .gems to default location

cp -R .gem $HOME

# Verify the gems
$URU_RUNNER gem list --local

# Check it the required gems are present
$URU_RUNNER gem list| grep -qi serverspec
if [ $? != 0 ] ; then
  echo 'WARNING: serverspec gem is not found in this environment:'
  exit 1
fi

# Run the spec
$URU_RUNNER ruby ruby/lib/ruby/gems/${GEM_VERSION}/gems/rake-${RAKE_VERSION}/bin/rake spec

