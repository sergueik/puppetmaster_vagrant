package TestParser::Parser::Example;

use strict;
use Data::Dumper;
use vars qw ($site);

sub new {

    my ($pkg) = @_;
    my $self = {};
    $site = 'dummy.html';

    my $class = ref $pkg || $pkg;
    bless $self, $class;
    $self->{site} = $site;
    return $self;

}

sub parse {
    my ($self) = shift;
    my $o = shift;

}

sub site {
    my ($self) = shift;
    my $site = shift;
    if ($site) {
        $self->{site} = $site;
    }
    $self->{site};

}
1;
__END__
