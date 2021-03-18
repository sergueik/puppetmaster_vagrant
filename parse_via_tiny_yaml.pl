#!/usr/bin/perl

use strict;

use Getopt::Long;
# NOTE: JSON is available in git bash Perl but not on a generic Linux vanilla box (solvable though cpan) 
use JSON;
BEGIN {
  use constant RELEASE => 0;
  use constant HOME => ( do { $_ = $ENV{HOME}; /\/([^\/]+)$/ });
  if (RELEASE) {
  # TODO: set extra lib path in RELEASE
  } else {
    unshift( @INC, `pwd` );
  }
}
# alternatively execute with I option
# perl -I . parse_via_tiny_yaml.pl -input data.yml -output result.yaml -dump

use YAML::Tiny;

# NOTE: do not expect  Data::Dumper to be available
# e.g. in git bash Perl install
# use Data::Dump;

my $inputfile = undef;
my $outputfile = undef;
my $debug = 0;
my $dump = 0;

GetOptions( 'input=s' => \$inputfile,	
  'output=s' => \$outputfile,
  'debug' => \$debug,
  'dump' => \$dump
);

# NOTE: alternatively, ($inputfile,$outputfile,) = @ARGV;
if ( $debug ){
  print "inputfile = $inputfile\n";
  print "outputfile = $outputfile\n";
  print "debug = $debug\n";
}

# see https://metacpan.org/pod/YAML::Tiny
my $data = YAML::Tiny->read( $inputfile );

# NOTE: YAML::Tiny side effect: everything is wrapped in an array
my $real_data = $data->[0];

# NOTE: drilling into data can be time consuming
# print $real_data; # HASH(0x80021c690)
# print join("\n", keys %$real_data);
# for(keys %$real_data){
#  print $real_data->{$_}, "\n";
# }
# pipeline
# ARRAY(0x5559f7543a28)
# etc. etc.

if ($dump){
  our $json = JSON->new->allow_blessed;
  # see https://metacpan.org/pod/JSON#allow_blessed
  print "Result:\n", $json->pretty->encode($data->[0]);

}
if ($outputfile ){
  # Save the document back to the file
  $data->write( $outputfile );
}
1;
__END__
# cpan get 'YAML::Tiny'
# copy to /tmp and explode
# Open the config
# perl -I . -MYAML::Tiny -e '{print 1}'
