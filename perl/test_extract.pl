#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;
use Data::Dumper qw(Dumper);
use HTML::TagParser; # https://metacpan.org/pod/HTML::TagParser

use vars qw(@data $element @elements);

my $filename = 'links.htm'; # http://www.louisianaoutdoorproperties.com
my $html     = HTML::TagParser->new($filename);
$element = ($html->getElementsByAttribute( 'id', 'acListWrap' ))[0]->subTree();

@elements = $element->getElementsByAttribute( 'class', 'listSubtitle' );
print "Number of nodes: " . scalar(@elements) . "\n";
@data = map { $_->innerText } @elements;
print Dumper \@data;

@elements =
  $element->getElementsByAttribute( 'class', 'acListPrice' );
print "Number of nodes: " . scalar(@elements) . "\n";
@data = map { $_->innerText } @elements;
print Dumper \@data;

@elements =
  $element->getElementsByAttribute( 'class', 'lower tabsection' );
print "Number of nodes: " . scalar(@elements) . "\n";
@data = map { my $text = $_->innerText; $text =~ s|\s+| |g;  $text } @elements;
print Dumper \@data;
