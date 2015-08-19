#!/usr/bin/env bash
# https://github.com/grahamgilbert/vagrant-puppetmaster/tree/master/puppet
set +e
LSB_RELEASE=$(/usr/bin/lsb_release -a 2>1 | grep -a 'release')
set -e
if [[ "$LSB_RELEASE" =~ '12.' ]]
then
PACKAGE_URL='http://apt.puppetlabs.com/puppetlabs-release-precise.deb'
else
PACKAGE_URL='http://apt.puppetlabs.com/puppetlabs-release-trusty.deb'
fi

if [ "$EUID" -ne '0' ]; then
  echo 'This script must be run as root.' >&2
  exit 1
fi

echo "Configuring PuppetLabs package ${PACKAGE_URL} locally"
REPO_LOCAL_PATH=$(mktemp)
wget --output-document=${REPO_LOCAL_PATH} ${PACKAGE_URL} 2>/dev/null
dpkg -i ${REPO_LOCAL_PATH} >/dev/null
apt-get update >/dev/null

echo 'Installing Puppet'
apt-get install -y puppet >/dev/null

echo "Puppet " $(puppet --version) " installed!"
