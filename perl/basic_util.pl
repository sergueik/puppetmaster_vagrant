#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;
use Data::Dumper qw(Dumper);
use List::Util qw(max);

use vars qw($DEBUG $MAX $DATA);
$DEBUG = 0;

my $result = GetOptions (

   'max=i'   => \$MAX, # integer
    'data=s' => \$DATA,
    'debug'  => \$DEBUG,

);
my $rawdata = undef;

if ( $DATA && -f $DATA  ) {
  print "Reading data: $DATA " if $DEBUG;
  open (FH ,$DATA);
  $rawdata = do { local $/; <FH> };
  close(FH);

}
our @provided_numbers= ();
$rawdata ||= <<DATA;
1 3;4,5;6
7:20
8
11
19
18
18:18:18:20
10
12
13
DATA
@provided_numbers = split /(?:\s+|(?:\r?\n)+|:|;|,)/, $rawdata;
# cast
map {$_ = 0 + $_ } @provided_numbers;
our $b = {};

print Dumper \@provided_numbers if $DEBUG;
map {$b->{$_} = 1 } @provided_numbers;
$MAX =  max( @provided_numbers ) unless $MAX;
print "max (\@provided_numbers) = ${MAX}\n" if $DEBUG;
my @missing_numbers = grep {  !defined($b->{$_}) } 1..$MAX + 1 ;
print 'Number of missing numbers: ' . scalar(@missing_numbers) ."\n" if $DEBUG;
if (scalar(@missing_numbers)){
  print join( "\n", @missing_numbers ) . "\n";
} else {
  print 'Nothing is missing';
}
# print Dumper($b) if $DEBUG;

