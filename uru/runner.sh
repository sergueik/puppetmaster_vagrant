#!/bin/sh

export URU_HOME='/uru'
export URU_INVOKER=bash
export GEM_VERSION=2.1.0
export RAKE_VERSION=10.1.0
export RUBY_VERSION=2.1.9
export LD_LIBRARY_PATH=${URU_HOME}/ruby/lib

pushd ${URU_HOME}

# TODO: ./uru_rt admin refresh
# if the  ~/.uru/rubies.json is different, in particular the GemHome
# TODO: remove uru/ruby/lib/ruby/gems/2.1.0/gems/gems/
echo Y |./uru_rt  admin rm  219p490
./uru_rt admin add ruby/bin

export TAG=$(./uru_rt  ls 2>& 1|awk -e '{print $1}')
./uru_rt $TAG
./uru_rt ls --verbose

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
# TODO: fix it properly
# Copy .gems to default location

cp -R .gem ~

# Verify the gems
./uru_rt gem list| grep -qi serverspec
if [ $? != 0 ] ; then
  echo 'WARNING: serverspec gem is not found in this environment:'
  ./uru_rt gem list
  # exit 1
fi

# Actually run the spec
./uru_rt ruby ruby/lib/ruby/gems/${GEM_VERSION}/gems/rake-${RAKE_VERSION}/bin/rake spec


# Process the results

./uru_rt ruby <<EOF

require 'json'
require 'pp'

REPORT = 'reports/report_.json'
report_json = File.open(REPORT)

report_obj = JSON.parse(report_json.read, symbolize_names: true)
report_obj[:examples].each do |example|
  if example[:status] !~ /passed/i
    pp [example[:status],example[:full_description]]
  end
end
pp report_obj[:summary_line]
EOF
