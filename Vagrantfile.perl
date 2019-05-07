  # -*- mode: ruby -*-
# vi: set ft=ruby :

# based on:
# https://github.com/williambelle/perl-box
# collapsed into single, fixed few Vagrant specific issues

perl_version = ENV.fetch('PERL_VERSION', '5.28.0') # TODO: use to suppress brew
# e.g. 5.28.0

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
        sudo apt-get -qqy install perl-doc perltidy libperl-critic-perl
        sudo apt-get -qqy apache2 lynx
	sudo apt-get install libhtml-tokeparser-simple-perl libmath-polygon-perl libossp-uuid-perl libregexp-common-perl
        # https://tecadmin.net/enable-or-disable-cgi-in-apache24/
        # https://httpd.apache.org/docs/2.4/howto/cgi.html
        # http://www.wellho.net/forum/Perl-Programming/Running-Perl-CGI-scripts-under-Apache-Tomcat.html
        sudo a2enmod cgi
        sudo systemctl restart httpd
        PERL_MODULES='JSON Date::Manip Date::Parse CGI::FastTemplate Test::CheckManifest Carp Test::Pod::Coverage Test::CheckManifest Test::Pod::Coverage Test::Pod Test::Perl::Critic Data::Dumper IO::Compress::Brotli CGI Time::HiRes Time::CTime Time::Local Time::ParseDate File::Basename List::MoreUtils Math::Trig Data::UUID HTML::TokeParser::Simple Math::Polygon Regexp::Common Regexp::Assemble::Compressed XML::Simplei GetOpt::Long'
        for M in $PERL_MODULES; do  cpan install $M; done

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
	# Install Perl dev dependencies for both old and new Perl versions. TODO: do the same in the system Perl to made vailable to apache2 CGI-BIN
        for M in $PERL_MODULES; do  $PERLBREW_BIN exec cpanm $M; done

        chown -R vagrant:vagrant ~vagrant/perl5

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
