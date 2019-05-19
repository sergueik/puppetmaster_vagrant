#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;
use Data::Dumper qw(Dumper);
use List::Util qw(max);
use HTML::TagParser;

use vars qw($DEBUG $MAX $DATA);
$DEBUG = 0;

sub getSubTree($$$) {
    my ( $e, $n, $v ) = @_;
    my @e = $e->getElementsByAttribute( $n, $v );
    $e[0]->subTree();
}

sub getData($$$) {
    my ( $e, $n, $v ) = @_;
    my @e = $e->getElementsByAttribute( $n, $v );
    my @d =
      map { my $t = $_->innerText; $t =~ s|\s+| |g; $t } @e;
    \@d;
}
my $filename = '1-acre-sale-several-greenhouses-residence-oneco-ct.html';

my $locatorChains = {
    'info' => {
        'names'  => [ 'class', 'class', 'class' ],
        'values' => [
            'region-content', ' group-info field-group-fieldset form-wrapper',
            'field-body'
        ]
    },
    'land_area' => {
        'names'  => [ 'class', 'class', 'class' ],
        'values' => [
            'region-content',
            ' group-property-land field-group-fieldset form-wrapper',
            'field-acres-total inline'
        ]
    },

    'price' => {
        'names'  => [ 'class', 'class', 'class' ],
        'values' => [
            'region-content',
            ' group-property-tenure field-group-fieldset form-wrapper',
            'field-sale-price'
        ]
    }
};
my $results = {};

foreach my $entry ( keys %$locatorChains ) {
    $results->{$entry} = undef;
    my $element = HTML::TagParser->new($filename);
    my $names   = $locatorChains->{$entry}->{'names'};
    my $values  = $locatorChains->{$entry}->{'values'};
    if ($DEBUG) {
        print Dumper($names);
        print Dumper($values);
    }
    foreach my $step ( 0 ... $#$names ) {
        if ( $step == $#$names ) {
            my $data = getData( $element, $names->[$step], $values->[$step] );
            print Dumper \$data if $DEBUG;
            $results->{$entry} = $data->[0];
        }
        else {
            $element =
              getSubTree( $element, $names->[$step], $values->[$step] );
        }
        print $step if $DEBUG;
    }
}

print Dumper \$results;

