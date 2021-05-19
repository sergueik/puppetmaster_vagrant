#!/usr/bin/perl
use strict;
use Getopt::Long;

# the data collected indo @data

use vars qw( @data $DEBUG);

my $inputfile  = undef;
my $DEBUG = 0;

GetOptions(
    'input=s'  => \$inputfile,
    'debug'    => \$DEBUG
);


@data  = ();

sub read_config {
    my ($config_path) = @_;
    my $last_line = undef;
    my $line_number;

    # slurp
    open( FILE, $config_path )
      || die "cannot read ${config_path}: $!";
    my @lines = <FILE>;
    close(FILE);

    for ( $line_number = 0 ; $line_number < @lines ; $line_number++ ) {
        for ( my $line = $lines[$line_number] ) {

          SWITCH: {
                if ( $line !~ /\S/ || $line =~ /^\s*#/ ) {
                    next;
                }
                print STDERR "examine $line" if $DEBUG;

                if ( $line =~ /^\s*!include\b\s+(\S+)/i ) {
                    print STDERR "process include after $last_line" if $DEBUG;
                    my $included_file = $1;

                    # Read the included file
                    &read_config($included_file);
                    print STDERR
                      "resume processing of $included_file after $last_line"
                      if $DEBUG;
                    next;
                }
                push( @data, $line );
                print STDERR "collected $last_line" if $DEBUG;
                $last_line = $line;
            }
        }
    }
}

&read_config($inputfile);
print @data;
1;
__END__
