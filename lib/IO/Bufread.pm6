=begin pod

=head1 NAME

IO::Bufread - Buffered reading of binary data

=head1 SYNOPSIS

    use IO::Bufread;
    my $handle  := open(‘example.txt’, :bin);
    my $bufread := IO::Bufread.new($handle);
    my $blob    := $bufread.read(10);
    say $blob;

=head1 DESCRIPTION

Reading binary input efficiently often requires that large amounts of data
are read at once. However, a more convenient interface allows reading a
specific number of bytes. The B<IO::Bufread> class offers both worlds, by
wrapping an underlying device together with an internal buffer.

The I<IO::Bufread> class can be instantiated with an underlying object of
type I<IO::Handle>, I<IO::Socket>, or I<Code>. When reading from any
I<IO::Bufread> object, the underlying object will be read from only when the
internal buffer is empty.

=end pod

unit class IO::Bufread;

has &!read;
has Blob $!buffer;

multi method new(IO::Handle:D $handle --> ::?CLASS:D)
{
    ::?CLASS.new({ $handle.read });
}

multi method new(IO::Socket:D $socket --> ::?CLASS:D)
{
    ::?CLASS.new({ $socket.recv(:bin) });
}

multi method new(&read --> ::?CLASS:D)
{
    self.bless(:&read);
}

submethod BUILD(::?CLASS:D: :&!read --> Nil)
{
}

method read(::?CLASS:D: Int:D $n --> Blob:D)
{
    $!buffer = &!read.() unless $!buffer;
    my $slice := $!buffer.subbuf(^$n);
    $!buffer = $!buffer.subbuf($slice.bytes);
    $slice;
}
