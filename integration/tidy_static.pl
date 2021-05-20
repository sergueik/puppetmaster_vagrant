#!/usr/bin/perl

use strict;

BEGIN {
    use constant RELEASE => 0;
    use constant HOME    => ( do { $_ = $ENV{HOME}; /\/([^\/]+)$/ } );
    if (RELEASE) {

        # TODO: set extra lib path in RELEASE
    }
    else {
        unshift( @INC, `pwd` );
        unshift( @INC, '.' );
    }
}

package main;
use Getopt::Long;

# https://metacpan.org/pod/distribution/Perl-Tidy/bin/perltidy
# use JSON:PP;
use Perl::Tidy;


my $arg_string = undef;
exit Perl::Tidy::perltidy( argv => $arg_string );
1;
__END__
# TODO: https://metacpan.org/pod/distribution/Perl-Tidy/bin/perltidy#EXAMPLES
my $inputfile  = undef;
my $outputfile = undef;
my $debug      = 0;
my $dump       = 0;

GetOptions(
    'input=s'  => \$inputfile,
    'output=s' => \$outputfile,
    'debug'    => \$debug,
    'dump'     => \$dump
);

# NOTE: alternatively, ($inputfile,$outputfile,) = @ARGV;
if ($debug) {
    print "inputfile = $inputfile\n";
    print "outputfile = $outputfile\n";
    print "debug = $debug\n";
}
my $err_data;
open my $fh, $inputfile;
my $inputfile_content = do { local $/; <$fh> };
close $fh;

print $inputfile_content;
my $outputfile_content = '';
my $error_flag = Perl::Tidy::perltidy(
    argv        => '-pbp',
    source      => \$inputfile_content,
    destination => \$outputfile_content,
    stderr      => \$err_data
);
print $outputfile_content;
1;

