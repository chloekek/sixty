=begin pod

=head1 NAME

HTTP::Server::Response - HTTP responses

=head1 SYNOPSIS

    use HTTP::Server::Response;

    my $response := HTTP::Server::Response.new(
        status-code => 200,
        reason-phrase => ‘OK’,
        headers => %(Content-Type => ‘text/html’),
        body => -> $to { $to.write(‘<h1>Hello, world!</h1>’) },
    );

    $response.write($*OUT);

=head1 DESCRIPTION

The B<HTTP::Server::Response> class provides a data type for HTTP responses
and a method for writing HTTP 1.1 responses.

=head2 Response body

The response body must be a routine that accepts any object with a write
method with the signature C<(Blob:D --E<gt> Nil)>N<The I<IO::Handle:D> and
I<IO::Socket:D> types satisfy this requirement>.

When writing a response with the I<write> method, the object passed to the
body routine properly handles chunked encoding and compression based on the
headers.

=end pod

unit class HTTP::Server::Response;

has Int $.status-code is required;
has Str $.reason-phrase is required;
has Str:D %.headers{Str:D};
has &.body is required;

method write(::?CLASS:D: $to --> Nil)
{
    my constant CRLF = “\r\n”.encode;
    self!write-status-line($to);
    self!write-headers($to);
    $to.write(CRLF);
    # TODO: Handle chunked and compressed encoding.
    &!body($to);
}

method !write-status-line(::?CLASS:D: $to --> Nil)
{
    $to.write(“HTTP/1.1 $!status-code $!reason-phrase\r\n”.encode);
}

method !write-headers(::?CLASS:D: $to --> Nil)
{
    for %!headers.sort -> (:$key, :$value) {
        $to.write(“$key: $value\r\n”.encode);
    }
}
