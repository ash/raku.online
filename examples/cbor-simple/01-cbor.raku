#!/usr/bin/env rakupp
# CBOR::Simple — Encoding, and what the bytes say
# https://raku.online/modules/cbor-simple/#encoding-and-what-the-bytes-say
#
# Install what it needs, then run it:
#     rakupp install CBOR::Simple
#     rakupp 01-cbor.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use CBOR::Simple;

for 42, -1, 1.5e0, 'hi', [1, 2, 3], True, Any -> $v {
    my $b = cbor-encode($v);
    say sprintf('%-12s %-22s %s',
                $v.raku, $b.list».fmt('%02x').join(' '), cbor-diagnostic($b));
}
say '';
my %deep = name => 'raku', revisions => <6.c 6.d 6.e>, stable => True;
my $enc  = cbor-encode(%deep);
my %back = cbor-decode($enc);
say 'a nested round trip: ', $enc.bytes, ' bytes';
say '  keys     ', %back.keys.sort.join(' ');
say '  revisions ', %back<revisions>.join(' ');
say '  stable   ', %back<stable>;

# Output:
#     42           18 2a                  42
#     -1           20                     -1
#     1.5e0        fa 3f c0 00 00         1.5_2
#     "hi"         62 68 69               "hi"
#     $[1, 2, 3]   83 01 02 03            [1, 2, 3]
#     Bool::True   f5                     true
#     Any          f6                     null
#     
#     a nested round trip: 42 bytes
#       keys     name revisions stable
#       revisions 6.c 6.d 6.e
#       stable   True
