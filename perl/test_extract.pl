#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;
use Data::Dumper qw(Dumper);
use HTML::TagParser; # https://metacpan.org/pod/HTML::TagParser

use vars qw(@data @elements @elements2);

my $filename = 'links.htm'; # http://www.louisianaoutdoorproperties.com
my $html     = HTML::TagParser->new($filename);
@elements = $html->getElementsByAttribute( 'id', 'acListWrap' );
print "Number of nodes: " . scalar(@elements) . "\n";

@elements2 =
  $elements[0]->subTree()->getElementsByAttribute( 'class', 'listSubtitle' );
print "Number of nodes: " . scalar(@elements2) . "\n";
@data = map { $_->innerText } @elements2;
print Dumper \@data;

@elements2 =
  $elements[0]->subTree()->getElementsByAttribute( 'class', 'acListPrice' );
print "Number of nodes: " . scalar(@elements2) . "\n";
@data = map { $_->innerText } @elements2;
print Dumper \@data;

@elements2 =
  $elements[0]->subTree()->getElementsByAttribute( 'class', 'lower tabsection' );
print "Number of nodes: " . scalar(@elements2) . "\n";
@data = map { my $text = $_->innerText; $text =~ s|\s+| |g;  $text } @elements2;
print Dumper \@data;
