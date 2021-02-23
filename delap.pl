#!/usr/bin/perl

use strict;
use Getopt::Long;

my $inputfile = undef;
my $outputfile = undef;
my $debug = 0;

GetOptions( 'input=s' => \$inputfile,	
  'output=s' => \$outputfile,
  'debug' => \$debug
);
# alternatively, ($inputfile,$outputfile,) = @ARGV;
print "input = $inputfile\n";
print "output =$outputfile\n";
print "debug = $debug\n";
my $CONFIG = <<EOF;
x: |
a
b
c

y:a,c,b

z:d,e
t:|
x
y

u: |
a

v1,v2,v3: |
b
c
d,e,f
g,h

w:c,d,e
EOF
my $NLS= '#';
my $data = $CONFIG;
$data =~  s|\n|$NLS|mg;
if ($inputfile) {	
  open(FH, '<', $inputfile) or die $!;
  while(<FH>){
    chomp;
    $data .= $_ ;
    $data .= $NLS;
  }
  close(FH);
}

my $NONLS = '[^#]';
my $DELIMITER = '\|';
my $NODELIMITER = '[^\|]';

print "Regexp:\n" , '^(?:($NODELIMITER+)$NLS)*($NONLS+): *$DELIMITER$NLS((?:$NONLS+$NLS?)*)$NLS$NLS(.*$)' , "\n" if $debug;
# NOTE: $) is a special Perl variable
# e.g. perl -e 'print $)'
# will print
# 1000 4 24 27 30 46 118 126 128 1000
# addind a space beween the $ and the ) does not help

print "Regexp:\n" , "^(?:($NODELIMITER+)$NLS)*($NONLS+): *$DELIMITER$NLS((?:$NONLS+$NLS?)*)$NLS$NLS(.*$)" , "\n" if $debug;

# counter to prevent runaway scans
my $cnt = 0;

while (($data =~ /^(?:($NODELIMITER+)$NLS)*($NONLS+): *$DELIMITER$NLS((?:$NONLS+$NLS?)*)$NLS$NLS(.*$)/mo) ) {
  if ($cnt++ > 20) {
    last;
  }
  print "Data:\"$data\"\n" if $debug;
  print "Loop:$cnt\n" if $debug;

  my $regular_config = $1;
  $data = $4;
  my $property_name = $2;
  my $property_values = $3;
  if ($debug) {
    print "\$1 => ",$1, "\n";
    print "\$2 => ",$2, "\n";
    print "\$3 => ",$3,"\n";
    print "\$4 => ",$4,"\n";
  }
  print "\n${property_name}:". join(',',split( /$NLS/, $property_values)),"\n\n" ;
  print join ("\n", split( /$NLS/, $regular_config)), "\n";

}
print "After the loop\nData: \"${data}\"\n" if $debug;
if ($data =~ /\S/) {
  my $regular_config = $data;
  print join ("\n", split( /$NLS/, $regular_config)), "\n";

}
