#!/usr/bin/perl

use warnings;
use strict;
use POSIX;
use Getopt::Long;
use Data::Dumper qw(Dumper);
use List::Util qw(max);

use vars qw($DEBUG $MODS $NUMBER $RESULT);
$DEBUG  = 0;
$NUMBER = 1776;
my $dummy = GetOptions(

    'num=i' => \$NUMBER,    # integer
    'debug' => \$DEBUG,

);
$MODS = {
    'I' => 1,
    'V' => 5,
    'X' => 10,
    'L' => 50,
    'C' => 100,
    'D' => 500,
    'M' => 1000
};
my $result = [];
my $number = $NUMBER;
foreach my $key ( sort { $MODS->{$b} <=> $MODS->{$a} } keys %$MODS ) {
    my $denom = $MODS->{$key};
    print "Processing ${denom}\n" if $DEBUG;
    my $val = floor( $number / $denom );
    if ( $val != 0 ) {
        push @$result, ($key) x $val;
    }
    $number -= $val * $denom;
    print "Remainder ${number}\n" if $DEBUG;
}
$RESULT = join '', @$result;
print Dumper $result if $DEBUG;
print $RESULT, "\n";
