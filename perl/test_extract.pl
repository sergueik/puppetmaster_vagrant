#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;
use Data::Dumper qw(Dumper);
use HTML::TagParser;    # https://metacpan.org/pod/HTML::TagParser

use vars qw($element $data $result $DEBUG);

my $filename = 'links.htm';    # http://www.louisianaoutdoorproperties.com
my $html = HTML::TagParser->new($filename);
$element =
  ( $html->getElementsByAttribute( 'id', 'acListWrap' ) )[0]->subTree();

sub getData($$$) {
    my ( $parentElement, $attributeName, $attributeValue ) = @_;
    my @elements =
      $parentElement->getElementsByAttribute( $attributeName, $attributeValue );
    print "Number of nodes: " . scalar(@elements) . "\n" if $DEBUG;
    my @data =
      map { my $text = $_->innerText; $text =~ s|\s+| |g; $text } @elements;
    if ($DEBUG) {
        print "Attribute name: ${attributeName} value: ${attributeValue}\n";
        print Dumper \@data;
    }
    return \@data;

}
$result = {};
$data = getData( $element, 'class', 'acListPrice' );
$result->{'price'} = $data;

$data = getData( $element, 'class', 'listSubtitle' );
$result->{'title'} = $data;

$data = getData( $element, 'class', 'lower tabsection' );
$result->{'description'} = $data;
print Dumper \$result ;
