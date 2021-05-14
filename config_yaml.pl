#!/usr/bin/perl

use strict;
use Getopt::Long;

# use Data::Dumper;
BEGIN {
 use constant RELEASE => 0;
 use constant HOME => (
  do { $_ = $ENV{HOME}; /\/([^\/]+)$/ }
 );
 if (RELEASE) {

  # TODO: set extra lib path in RELEASE
 }
 else {
  unshift( @INC, `pwd` );
  unshift( @INC, '.' );
 }
}

# ./config_yaml.pl  --input config.yaml --servers --arg EAST --dump --debug --inint
# alternatively execute as a Perl scipt but need an extra I option
# perl -I . config_yaml.pl --init --output config.yaml
# perl -I . config_yaml.pl --input config.yaml --output result.yaml

use YAML::Tiny;
use JSON::PP;

# NOTE: do not expect  Data::Dumper to be available
# e.g. in git bash Perl install
# use Data::Dump;

my $inputfile  = undef;
my $outputfile = undef;
my $debug   = 0;
my $dump    = 0;
my $init    = 0;
my $servers = 0;
my $arg  = undef;
my $data    = undef;
my $real_data  = undef;
my $json_pp = JSON::PP->new->ascii->pretty->allow_nonref;

GetOptions(
 'input=s'  => \$inputfile,
 'output=s' => \$outputfile,
 'debug' => \$debug,
 'arg=s' => \$arg,
 'dump'  => \$dump,
 'servers'  => \$servers,
 'init'  => \$init
);

# NOTE: alternatively, ($inputfile,$outputfile,) = @ARGV;
if ($debug) {
 print "inputfile = $inputfile\n";
 print "outputfile = $outputfile\n";
 print "debug = $debug\n";
 print "dump = $dump\n";
 print "arg = $arg\n";
 print "servers = $servers\n";
 print "init = $init\n";
}

sub get_servers {
  my ($yaml, $key) = @_;
  get_property($yaml, $key , 'servers');
}
sub get_property {
  my ($yaml, $key, $property ) = @_;
  @{$yaml->{$key}->{$property}};
}
if ( !$init && !$inputfile ) {
  print STDERR "missing options: init or inputfile";
  exit 0;
}
if ($init) {
  my $configuration = {
    'EAST' => {
      'groups'  => [ 'first',   'second' ],
      'servers' => [ 'server1', 'server2', 'server3', 'server4' ]
    }
  };
  $real_data = $data = $configuration;
}
else {
  # see https://metacpan.org/pod/YAML::Tiny
  $data = YAML::Tiny->read($inputfile);

  # NOTE: YAML::Tiny side effect: everything is wrapped in an array
  $real_data = $data->[0];

  # NOTE: drilling into data can be time consuming
  # print $real_data; # HASH(0x80021c690)
  # print join("\n", keys %$real_data);
  # for(keys %$real_data){
  #  print $real_data->{$_}, "\n";
  # }
  # pipeline
  # ARRAY(0x5559f7543a28)
  # etc. etc.

  if ($dump) {
    print "Result:\n", $json_pp->encode($real_data);
  }
}

if ( $arg && $servers ) {
  if ($dump) {
    print "Result:\n", $json_pp->encode( $real_data->{$arg} );
  }
  print STDERR join "\n", get_servers( $real_data, $arg );
}
if ($outputfile) {
  if ($init) {

    # Initialize the configuration into the file
    my $rawdata = Dump($data);
    open( DATA, '>', $outputfile ) or die $!;
    print DATA $rawdata;
    flush DATA;
    close(DATA);
  } else {
    # Save the document back to the file
    $data->write($outputfile);
  }
}
1;
__END__
