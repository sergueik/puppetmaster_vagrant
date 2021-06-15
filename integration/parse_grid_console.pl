#!/usr/bin/perl

use strict;

BEGIN {
    use constant RELEASE    => 0;
    use constant HOME       => ( do { $_ = $ENV{HOME}; /\/([^\/]+)$/ } );
    use constant SCRIPT_DIR => (
        do { my $s = `dirname $0`; chomp $s; $s }
    );
    if (RELEASE) {

        # TODO: set extra lib path in RELEASE
    }
    else {
        unshift( @INC, `pwd` );
        unshift( @INC, SCRIPT_DIR );
    }
}

package main;
use Getopt::Long;

# https://github.com/makamaka/JSON-PP
use JSON::PP;

# https://github.com/kawanet/HTML-TagParser
use HTML::TagParser;

my $debug_html = undef;
my $remove_port = undef;
my $url      = undef;
my $filename = 'grid_console.html';

my $html = HTML::TagParser->new( $url ? $url : $filename );
our $json_pp = JSON::PP->new->ascii->pretty->allow_nonref->allow_blessed;

my $id    = 'helplink';
my @texts = ();
my @htmls = ();

=pod
my $element = $html->getElementById($id);
if ($element) {
    print "Result (1):\n", $json_pp->encode( $element->getAttribute('id') );
}
else {
    print "Failed to find column by id ${id}\n";
}
=cut

foreach my $column_id ( 'leftColumn', 'rightColumn' ) {
    my $column = $html->getElementById($column_id);
    if ($column) {
        my $text     = $column->innerText();
        my $subhtml  = $column->subTree();
        my @elements = $subhtml->getElementsByClassName('proxyname');
        if ($debug_html) {
            print "Result (2): ", $#elements, " elements\n";
        }

        # my @elements = $html->getElementsByClassName('proxyname');
        for my $element (@elements) {

            my $subhtml  = $element->subTree();
            my $element2 = ( $subhtml->getElementsByClassName('proxyid') )[0];
            my $text     = $element2->innerText();
            if ($remove_port){
            $text =~ s|.*http:\/\/\b(\w+):\d+s\b.*$|\1|o;
		} else { 
			$text =~ s|.*http:\/\/\b(\w+:\d+)\b.*$|\1|o;
			}
            push @texts, $text;
        }
    }
    else {
        if ($debug_html) {
            print "Failed to find column by id ${column_id}\n";
        }
    }
}
print $json_pp->encode( \@texts );
1;
__END__
