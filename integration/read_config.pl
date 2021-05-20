#!/usr/bin/perl
use strict;
use Getopt::Long;

# the data collected indo @data

use vars qw( @data %files $DEBUG);

my $inputfile = undef;
my $DEBUG   = 0;

GetOptions(
  'input=s' => \$inputfile,
  'debug'   => \$DEBUG
);

@data  = ();
%files = ();

sub read_config {
  my ($config_file) = @_;
  $files{$config_file} = 1;

  my $last_line = undef;
  my $line_number;

  # slurp
  open( FILE, $config_file )
    || die "cannot read ${config_file}: $!";
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
          my $included_file = $1;

          print STDERR "process include $included_file "
            . ( $last_line ? "after $last_line\n" : "\n" )
            if $DEBUG;
          if ( $files{$included_file} ) {
            die(
              'inclusion loop detected. The ', $included_file,
              ' that was already loaded, is referenced again from ',  $config_file
            );
          }

          # Read the included file
          &read_config($included_file);
          print STDERR "resume processing of $config_file "
            . ( $last_line ? "after $last_line\n" : "\n" )
            if $DEBUG;
          next;
        }
        push( @data, $line );
        $last_line = $line;
        print STDERR "collected $last_line" if $DEBUG;
      }
    }
  }
}

&read_config($inputfile);
print @data;
1;
__END__

#Copyright (c) 2021 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

