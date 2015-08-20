#!/usr/bin/env bash
# https://github.com/grahamgilbert/vagrant-puppetmaster/tree/master/puppet
set -e
source /etc/lsb-release
PACKAGE_URL="http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"

if [ "$EUID" -ne '0' ]
then
   echo 'This script must be run as root.' >&2
   exit 1
fi

if [[ "$DISTRIB_CODENAME" =~ 'precise' ]]
then
   apt-get remove -y puppet puppet-common
   apt-get autoremove -y
fi

echo "Configuring PuppetLabs package ${PACKAGE_URL} locally"
PACKAGE_LOCAL=$(mktemp)
wget --output-document=${PACKAGE_LOCAL} ${PACKAGE_URL} 2>/dev/null
dpkg -i ${PACKAGE_LOCAL} >/dev/null
apt-get update >/dev/null

echo 'Installing Puppet'
apt-get install -y puppet >/dev/null

echo "Puppet " $(puppet --version) " installed"

echo 'Installing git'
apt-get install -y git >/dev/null

if [[ "$DISTRIB_CODENAME" =~ 'precise' ]]
then
   apt-get update >/dev/null
   echo "Installing ruby 1.9.3..."
   apt-get install -y ruby1.9.1 ruby1.9.1-dev \
   rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 \
   build-essential libopenssl-ruby1.9.1 \
   libssl-dev zlib1g-dev >/dev/null
   
   update-alternatives --set ruby /usr/bin/ruby1.9.1
   update-alternatives --set gem /usr/bin/gem1.9.1
fi

if which r10k > /dev/null
then
   echo 'r10k is already installed'
else
   # http://terrarum.net/blog/puppet-infrastructure-with-r10k.html
   echo 'Installing r10k'
   gem install r10k -y >/dev/null
fi

if [ -f '/vagrant/Puppetfile' ]
then
   echo 'fetch modules for puppet provisioner via r10k'
   cp '/vagrant/Puppetfile' .
   r10k puppetfile install
fi
echo 'All done'
