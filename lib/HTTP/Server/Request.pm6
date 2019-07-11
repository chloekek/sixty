=begin pod

=head1 NAME

HTTP::Server::Request - HTTP requests

=head1 SYNOPSIS

    use HTTP::Server::Request;
    use IO::Bufread;

    my $bufread := IO::Bufread.new(...);
    my $request := HTTP::Server::Request.read($bufread);

    say $request.method;
    say $request.request-uri;
    say $request.headers.perl;
    say $request.body.read(1024);

=head1 DESCRIPTION

The B<HTTP::Server::Request> class provides a data type for HTTP requests and
a method for reading HTTP 1.1 requests from an I<IO::Bufread> device. The
parser is rather lenient:

=item
a mere LF as line separator is sufficient; no CR needed; and

=item
the colon in a header may be followed by arbitrary whitespace, not just SP or
HT.

=end pod

unit class HTTP::Server::Request;

use IO::Bufread;
use X::HTTP::Header;
use X::HTTP::RequestLine;

has Str $.method is required;
has Str $.request-uri is required;
has Str:D %.headers{Str:D};
has IO::Bufread $.body is required;

method read(::?CLASS:U: IO::Bufread:D $from --> ::?CLASS:D)
{
    my ($method, $request-uri) := read-request-line($from);
    my %headers := read-headers($from);
    ::?CLASS.new(:$method, :$request-uri, :%headers, body => $from);
}

sub read-request-line(IO::Bufread:D $from --> List:D)
{
    my @request-line = $from.read-line.decode.split(‘ ’, 3);
    die(X::HTTP::RequestLine.new) unless @request-line == 3;
    @request-line[^2];
}

sub read-headers(IO::Bufread:D $from --> Hash:D)
{
    my Str:D %headers{Str:D};
    loop {
        my $line := $from.read-line.decode.chomp;
        last unless $line;

        my @line = $line.split(/‘:’\s*/, 2);
        die(X::HTTP::Header.new(:$line)) unless @line == 2;
        my $field-name  := @line[0];
        my $field-value := @line[1];

        %headers{$field-name} = $field-value;
    }
    %headers;
}
