#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;
use TestParser::Parser::Converter;

use vars qw($DEBUG $MODS $NUMBER $RESULT);
$DEBUG  = 0;
$NUMBER = 1776;
my $dummy = GetOptions(
    'num=i' => \$NUMBER,    # integer
    'debug' => \$DEBUG,
);
my $class  = 'TestParser::Parser::Converter';
my $converter = $class->new; 
my $number = $NUMBER;
$converter->number($number);
$converter->parse;
print "Result = " . ($converter->result) . "\n";
