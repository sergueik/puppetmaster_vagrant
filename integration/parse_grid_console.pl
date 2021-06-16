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

my $debug_html   = undef;
my $remove_port  = undef;
my $url          = 'http://localhost:4444/grid/console/';
my $filename     = 'grid_console.html';
my $tmp_filename = undef;

GetOptions(
    'url=s'   => \$url,
    'input=s' => \$filename,
    'remove_port' => \$remove_port,
    'debug'   => \$debug_html
);

if ($url) {
    if ( !defined $URI::Fetch::VERSION ) {
        local $@;
        # https://metacpan.org/pod/URI::Fetch
        eval { require URI::Fetch; };
        if ($@) {
            #  git bash Perl maybe
            $tmp_filename = "/tmp/a.$$.html";
            system( 'curl', '-o', $tmp_filename, $url );
        }
    }
}

my $html = HTML::TagParser->new(
    $url ? $tmp_filename ? $tmp_filename : $url : $filename );
my $json_pp        = JSON::PP->new->ascii->pretty->allow_nonref->allow_blessed;
my $subhtml        = undef;
my $text           = undef;
my @elements       = ();
my $element        = undef;
my $element2       = undef;
my @node_hostnames = ();
my @htmls          = ();

foreach my $column_id ( 'leftColumn', 'rightColumn' ) {
    my $column = $html->getElementById($column_id);
    if ($column) {
        $text     = $column->innerText();
        $subhtml  = $column->subTree();
        @elements = $subhtml->getElementsByClassName('proxyname');

        for my $element (@elements) {

            $subhtml  = $element->subTree();
            $element2 = ( $subhtml->getElementsByClassName('proxyid') )[0];
            $text     = $element2->innerText();
            if ($remove_port) {
                $text =~ s|.*http:\/\/\b([0-9a-z.-]+):\d+\b.*$|\1|o;
            }
            else {
                $text =~ s|.*http:\/\/\b([0-9a-z.-]+:\d+)\b.*$|\1|o;
            }
            push @node_hostnames, $text;
        }
    }
    else {
        if ($debug_html) {
            print "Failed to find column by id ${column_id}\n";
        }
    }
}
print $json_pp->encode( \@node_hostnames );
1;
__END__
