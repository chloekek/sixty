use IO::Bufread;
use Test;

subtest ‘tdata/bufread.txt’ => {
    my $handle := open(‘tdata/bufread.txt’, :bin);
    my $bufread := IO::Bufread.new($handle);
    cmp-ok($bufread.read(5), ‘eq’, ‘hello’.encode);
    cmp-ok($bufread.read(5), ‘eq’, ‘ worl’.encode);
    cmp-ok($bufread.read(5), ‘eq’, “d\n”.encode);
    cmp-ok($bufread.read(5), ‘eq’, ‘’.encode);
}

# TODO: Need a test with sockets.

subtest ‘die’ => {
    class X is Exception { }
    my $bufread := IO::Bufread.new({ die(X.new) });
    throws-like({ $bufread.read(5) }, X);
    throws-like({ $bufread.read(5) }, X);
}

done-testing;
