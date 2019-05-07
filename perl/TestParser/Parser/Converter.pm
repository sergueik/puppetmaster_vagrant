package TestParser::Parser::Converter;

use warnings;
use strict;

use POSIX;
use Getopt::Long;
use Data::Dumper qw(Dumper);
use List::Util qw(max);
use vars qw ($number $result $mods);
my $DEBUG;

sub new {

    my ($pkg) = @_;
    my $self = {};
    $number = 0;
    $result = '';
    $mods   = {
        'I' => 1,
        'V' => 5,
        'X' => 10,
        'L' => 50,
        'C' => 100,
        'D' => 500,
        'M' => 1000
    };

    my $class = ref $pkg || $pkg;
    bless $self, $class;
    $self->{number} = $number;
    return $self;

}

sub parse {
    my ($self)       = shift;
    my $roman_digits = [];
    my $number       = $self->{number};
    foreach my $key ( sort { $mods->{$b} <=> $mods->{$a} } keys %$mods ) {
        my $denom = $mods->{$key};
        print "Processing ${denom}\n" if $DEBUG;
        my $val = floor( $number / $denom );
        if ( $val != 0 ) {
            push @$roman_digits, ($key) x $val;
        }
        $number -= $val * $denom;
        print "Remainder ${number}\n" if $DEBUG;
    }
    my $result = join '', @$roman_digits;
    print Dumper $roman_digits if $DEBUG;
    $self->{result} = $result;
}

sub number {
    my ($self) = shift;
    my $number = shift;
    if ($number) {
        $self->{number} = $number;
    }
    $self->{number};

}

sub result {
    my ($self) = shift;
    $self->{result};
}
1;
__END__
