=begin pod

=head1 NAME

HTTP::Server - HTTP server

=head1 SYNOPSIS

    use HTTP::Server;

    sub on-request(HTTP::Server::Request:D $request
                   --> HTTP::Server::Response:D)
        {…}

    HTTP::Server::listen(
        localhost  => ‘0.0.0.0’,
        localport  => 80,
        on-error   => { $*ERR.say($^x) }
        :&on-request,
    );

=end pod

unit module HTTP::Server;

use HTTP::Server::Request;
use HTTP::Server::Response;
use IO::Bufread;

our sub listen(:$localhost, :$localport, |c --> Nil)
{
    my $listen := IO::Socket::INET.new(:listen, :$localhost, :$localport);
    serve($listen, |c);
}

our sub serve(IO::Socket::INET:D $listen, |c --> Nil)
{
    loop {
        my $client := $listen.accept;
        start { serve-client($client, |c) }
    }
}

our sub serve-client(IO::Socket::INET:D $client,
                     :&on-error = { $*ERR.say($^x) },
                     |c --> Nil)
{
    CATCH { default { on-error($_) } }
    LEAVE { $client.close }
    serve-request($client, |c);
}

our sub serve-request(IO::Socket::INET:D $client, :&on-request --> Nil)
{
    my $bufread := IO::Bufread.new($client);
    my $request := HTTP::Server::Request.read($bufread);
    my HTTP::Server::Response:D $response := on-request($request);
    $response.write($client);
}

=begin pod

=head1 BUGS

There is currently no support for keep-alive connections.

=end pod
