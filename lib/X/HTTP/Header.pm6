unit class X::HTTP::Header;

also is Exception;

has Str $.line is required;

method message
{
    “Bad header line: {$!line.perl}”;
}
