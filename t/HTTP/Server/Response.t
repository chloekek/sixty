use HTTP::Server::Response;
use Test;

subtest ‘tdata/response.http’ => {
    my $response := HTTP::Server::Response.new(
        status-code => 200,
        reason-phrase => ‘OK’,
        headers => %(Content-Type => ‘text/html’, X-Server => ‘Sixty’),
        body => { $^to.write(“Hello, world!\r\n”.encode) },
    );

    my $buffer = Blob.allocate(0);
    class writer { method write($data) { $buffer ~= $data } }
    $response.write(writer);

    my $expected := slurp(‘tdata/response.http’, :bin);
    cmp-ok($buffer, ‘eq’, $expected);
}

done-testing;
