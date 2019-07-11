use HTTP::Server::Request;
use IO::Bufread;
use Test;
use X::HTTP::Header;
use X::HTTP::RequestLine;

subtest ‘tdata/request.http’ => {
    my $handle := open(‘tdata/request.http’, :bin);
    my $bufread := IO::Bufread.new($handle);
    my $request := HTTP::Server::Request.read($bufread);

    cmp-ok($request.method,      ‘eq’, ‘GET’);
    cmp-ok($request.request-uri, ‘eq’, ‘/foo/bar’);

    cmp-ok($request.headers.elems, ‘==’, 2);
    cmp-ok($request.headers<Host>,           ‘eq’, ‘localhost:9000’);
    cmp-ok($request.headers<Content-Length>, ‘eq’, ‘0’);

    cmp-ok($request.body.read(15), ‘eq’, “Hello, world!\r\n”.encode);
    cmp-ok($request.body.read(15), ‘eq’, ‘’.encode);
}

subtest ‘tdata/bad-request-line.http’ => {
    my $handle := open(‘tdata/bad-request-line.http’, :bin);
    my $bufread := IO::Bufread.new($handle);
    throws-like({ HTTP::Server::Request.read($bufread) },
                X::HTTP::RequestLine);
}

subtest ‘tdata/bad-header.http’ => {
    my $handle := open(‘tdata/bad-header.http’, :bin);
    my $bufread := IO::Bufread.new($handle);
    throws-like({ HTTP::Server::Request.read($bufread) },
                X::HTTP::Header);
}

done-testing;
