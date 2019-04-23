  # -*- mode: ruby -*-
# vi: set ft=ruby :

# based on:
# https://github.com/williambelle/perl-box
# collapsed into single, fixed few Vagrant specific issues

perl_version = ENV.fetch('PERL_VERSION', '5.28.0') # TODO: use to suppress brew

box_name = ENV.fetch('BOX_NAME', 'puppetlabs/ubuntu-16.04-64-puppet')
debug_perl = ENV.fetch('DEBUG_PERL', '')
debug_perl = (debug_perl =~ (/^(true|t|yes|y|1)$/i))

debug = ENV.fetch('DEBUG', '')
debug = (debug =~ (/^(true|t|yes|y|1)$/i))

perl_old = '5.8.9 5.10.1 5.12.5 5.14.4 5.16.3 5.18.4 '
perl_new = '5.20.3 5.22.4 5.24.4 5.26.2 5.28.0'

VAGRANTFILE_API_VERSION = '2'

basedir = (ENV.fetch('HOME','') || ENV.fetch('USERPROFILE', '')).gsub('\\', '/')
box_memory = ENV.fetch('BOX_MEMORY', '1024').to_i

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box =  box_name
  # using localy cached vagrant box
  # invoke-webrequest -uri 'https://app.vagrantup.com/puppetlabs/boxes/ubuntu-16.04-64-puppet/versions/1.0.0/providers/virtualbox.box' -outfile "${env:USERPROFILE}\Downloads\ubuntu-16.04-64-puppet.box"
  config_vm_box_name =  'ubuntu-16.04-64-puppet.box'

  config.vm.box_url = "file://#{basedir}/Downloads/#{config_vm_box_name}"

      # only required for
      config.vm.boot_timeout = 600

      config.vm.synced_folder './' , '/vagrant'

      shell_script = <<-EOF
        sudo apt-get -qy update
        sudo apt-get -qqy install vim jq build-essential curl zlib1g-dev libssl-dev
        sudo apt-get -y install libperl-critic-perl
        export PERLBREW_ROOT='/home/vagrant/perl5/perlbrew'
        PERLBREW_BIN="${PERLBREW_ROOT}/bin/perlbrew"

        PERL_OLD='5.8.9 5.10.1 5.12.5 5.14.4 5.16.3 5.18.4 '
        PERL_NEW='5.20.3 5.22.4 5.24.4 5.26.2 5.28.0'
        # NOTE: cannot leave empty
        PERL_OLD='5.8.9'
        PERL_NEW='5.28.0'

        # Install Perlbrew.
        # NOTE: all temporary files being deleted.
        # NOTE: no way currently to override PERLBREW_ROOT
        # NOTE: installing as regular user
        curl -kL https://install.perlbrew.pl | bash

        # Add Perlbrew to PATH
        echo 'source ~/perl5/perlbrew/etc/bashrc' >> /home/vagrant/.bashrc

        # Install all Perl version
        $PERLBREW_BIN install-multiple --notest $PERL_OLD $PERL_NEW

        # Install cpanm
        $PERLBREW_BIN install-cpanm

        # NOTE: need to suppress cpanm testing during install: too time-consuming

        # Install Perl dev dependencies
        $PERLBREW_BIN exec cpanm Test::CheckManifest Test::Pod::Coverage
        $PERLBREW_BIN exec cpanm Test::Pod Test::Perl::Critic
        $PERLBREW_BIN exec cpanm IO::Compress::Brotli

        # Switch to latest new Perl version
        $PERLBREW_BIN switch perl-${PERL_NEW##* }
        # echo $PERL_NEW | rev| cut -f 1 -d' ' | rev
      EOF
      config.vm.provision 'shell',
        env: {
          'PERL_OLD' => perl_old,
          'PERL_NEW' => perl_new,
        },
        inline: shell_script
    end
