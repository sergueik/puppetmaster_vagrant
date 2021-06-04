#!/usr/bin/perl

use strict;

use Getopt::Long;

BEGIN {
    use constant RELEASE    => 0;
    use constant HOME       => ( do { $_ = $ENV{HOME}; /\/([^\/]+)$/ } );
    use constant SCRIPT_DIR => (
        do { my $s = `dirname $0`; chomp $s; $s }
    );
    if (RELEASE) {

        # TODO: set extra lib path in RELEASE
    }
    else {
        unshift( @INC, `pwd` );
        unshift( @INC, SCRIPT_DIR );
    }
}

# alternatively execute with I option
# perl -I . parse_via_xml_tree_pp.pl -input data.xml -dump

# origin: https://metacpan.org/pod/XML::TreePP
use XML::TreePP;

# orgin: https://metacpan.org/pod/JSON::PP
use JSON::PP;

# NOTE: do not expect  Data::Dumper to be available
# e.g. in git bash Perl install
# use Data::Dump;

my $inputfile  = undef;
my $outputfile = undef;
my $format     = undef;
my $debug      = 0;
my $dump       = 0;

GetOptions(
    'input=s'  => \$inputfile,
    'format=s' => \$format,
    'output=s' => \$outputfile,
    'debug'    => \$debug,
    'dump'     => \$dump
);
if ( defined($format) && $format =~ /(:?xml|json)/i ) {
    my $format_selected = $1;
    my $data = undef;
    my $xml_helper = XML::TreePP->new();
    $xml_helper->set( indent => 2 );
    our $json_helper = JSON::PP->new->utf8->pretty->allow_nonref;
    if ( $format_selected =~ /XML/i ) {
        $data = $xml_helper->parsefile($inputfile);

        if ($dump) {
            print $json_helper->encode($data);
        }
    }
    elsif ( $format_selected =~ /JSON/i ) {
        open my $fh, '<', $inputfile or die "Can't open file $!";
        my $raw_data = do { local $/; <$fh> };
        close $fh;
        $data = $json_helper->decode($raw_data);
        if ($dump) {
            print( $xml_helper->write($data) );
        }
    }
}
else {
    print STDERR 'unrecognised or unspecified format';
}

1;
__END__

  ./parse_via_xml_tree_pp.pl -input data.xml -dump -format xml
  ./parse_via_xml_tree_pp.pl -input data.json -dump -format json

