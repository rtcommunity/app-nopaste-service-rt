package App::Nopaste::Service::RT;
use strict;
use warnings;
use base 'App::Nopaste::Service';
use Error qw(:try);
use RT::Client::REST;
use RT::Client::REST::Ticket;

my ( $username, $password, $server ) = ( 'user', 'pass', 'https://rtsever' );

use File::Basename ();

sub nopaste {
    my $self = shift;
    $self->run(@_);
}

sub run {
    my ( $self, %arg ) = @_;
    my $rt = RT::Client::REST->new(
        server  => $server,
        timeout => 30,
    );

    try {
        $rt->login( username => $username, password => $password );
    }
    catch Exception::Class::Base with {
        die "problem logging in: ", shift->message;
    };
    my $ticket = RT::Client::REST::Ticket->new(
        rt      => $rt,
        queue   => $arg{chan} ? $arg{chan} : "General",
        subject => $arg{desc} ? $arg{desc} : "no subject",
    )->store( text => $arg{text} );
    return $self->return( $ticket->id );
}

sub return {
    my ( $self, $ticket_id ) = @_;
    return ( 1, sprintf( "%s/Ticket/Display.html?id=%d", $server, $ticket_id ) );
}

1;
