#!/bin/sh

export URU_HOME='/uru'
export URU_INVOKER=bash
export LD_LIBRARY_PATH=${URU_HOME}/ruby/lib

GEM_VERSION=2.1.0
RAKE_VERSION=10.1.0
RUBY_VERSION=2.1.0
RUBY_RUNTIME_ID='219p490'
URU_RUNNER="${URU_HOME}/uru_rt"

pushd ${URU_HOME}
# TODO: $URU_RUNNER admin refresh
# when the ~/.uru/rubies.json, in particular the GemHome, is different

export HOME='/root'
if [[ ! -d "$HOME/.uru" ]]; then mkdir "$HOME/.uru"; fi
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
echo Y |$URU_RUNNER  admin rm $RUBY_RUNTIME_ID > /dev/null
$URU_RUNNER admin add ruby/bin

$URU_RUNNER ls --verbose
export TAG=`$URU_RUNNER ls 2>& 1|awk '{print $1}'`
$URU_RUNNER $TAG

# TODO: fix it properly
# Copy .gems to default location

cp -R .gem $HOME

# Verify the gems
$URU_RUNNER gem list --local

# Check that the required gems are present
$URU_RUNNER gem list| grep -qi serverspec
if [ $? != 0 ]; then
  echo 'ERROR: serverspec gem is not found'
  exit 1
fi

# Run the serverspec
$URU_RUNNER ruby ruby/lib/ruby/gems/$GEM_VERSION/gems/rake-$RAKE_VERSION/bin/rake spec