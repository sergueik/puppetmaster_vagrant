#!/usr/bin/perl

use strict;

our $DEBUG = $ENV{'DEBUG'};
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
my $data = $CONFIG;
my $NLS= '#';
my $NONLS = '[^#]';
my $DELIMITER = '\|';
$data =~  s|\n|$NLS|mg;

print "test 1:\n";
print "regexp:\n$NONLS+): *$DELIMITER$NLS((?:$NONLS+$NLS?)*)$NLS$NLS(.*$)\n" if $DEBUG;

while ($data =~ /($NONLS+): *$DELIMITER$NLS((?:$NONLS+$NLS?)*)$NLS$NLS(.*$)/mo) {
  print "Data:\n$data\n" if $DEBUG;
  $data = $3;
  my $property_name = $1;
  my $property_values = $2;
  print "in the loop:\n" if $DEBUG;
  if ($DEBUG){
    print "\$1 => ",$1, "\n";
    print "\$2 => ",$2, "\n";
    print "\$3 => ",$3,"\n";
  }
  print "\n${property_name}:". join(',',split( /$NLS/, $property_values)),"\n\n" ;

}
print "test 2:\n";
my $NODELIMITER = '[^\|]';
print "Regexp:\n^(?:($NODELIMITER)+$NLS)*\n" if $DEBUG;
my $data1 = 'y=a,c,b##z=d,e,f,g#';
if ($data1 =~ /^(?:($NODELIMITER+)$NLS)*/){ 
  print "match: $1\n";
}  else { 
  print "no match\n";

}
print "test 3:\n";
# keep regular config lines
$data = $CONFIG;
# relace new line characters to avoid dealing with multiline regexp
$NLS= '#';
$NONLS = '[^#]';
$data =~  s|\n|$NLS|mg;

print "Regexp:\n" , '^(?:($NODELIMITER+)$NLS)*($NONLS+): *$DELIMITER$NLS((?:$NONLS+$NLS?)*)$NLS$NLS(.*$)' , "\n" if $DEBUG;
# NOTE: $) is a special Perl variable
# e.g. perl -e 'print $)'
# will print
# 1000 4 24 27 30 46 118 126 128 1000
# addind a space beween the $ and the ) does not help

print "Regexp:\n" , "^(?:($NODELIMITER+)$NLS)*($NONLS+): *$DELIMITER$NLS((?:$NONLS+$NLS?)*)$NLS$NLS(.*$)" , "\n" if $DEBUG;

# prevent runaway scans
my $cnt = 0;

while (($data =~ /^(?:($NODELIMITER+)$NLS)*($NONLS+): *$DELIMITER$NLS((?:$NONLS+$NLS?)*)$NLS$NLS(.*$)/mo) ) {
  if ($cnt++ > 20) { 
    last;
  }
  print "Data:\"$data\"\n" if $DEBUG;
  print "Loop:$cnt\n" if $DEBUG;

  my $regular_config = $1;
  $data = $4;
  my $property_name = $2;
  my $property_values = $3;
  if ($DEBUG) {
    print "\$1 => ",$1, "\n";
    print "\$2 => ",$2, "\n";
    print "\$3 => ",$3,"\n";
    print "\$4 => ",$4,"\n";
  }
  print "\n${property_name}:". join(',',split( /$NLS/, $property_values)),"\n\n" ;
  print join ("\n", split( /$NLS/, $regular_config)), "\n";

}
print "After the loop\nData: \"${data}\"\n" if $DEBUG;
if ($data =~ /\S/) { 
  my $regular_config = $data;
  print join ("\n", split( /$NLS/, $regular_config)), "\n";

}
