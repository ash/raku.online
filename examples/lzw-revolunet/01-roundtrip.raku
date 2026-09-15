#!/usr/bin/env rakupp
# LZW::Revolunet — Round trips
# https://raku.online/modules/lzw-revolunet/#round-trips
#
# Install what it needs, then run it:
#     rakupp install LZW::Revolunet
#     rakupp 01-roundtrip.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LZW::Revolunet;

my $lzw = LZW::Revolunet.new;

for 'hello hello hello hello',
    'TOBEORNOTTOBEORTOBEORNOT',
    'a' x 30,
    'abc' -> $in {
    my $c = $lzw.compress(s => $in);
    my $d = $lzw.decompress(s => $c);
    say sprintf('%3d chars in -> %3d chars out   round trip %s',
        $in.chars, $c.chars, $d eq $in ?? 'exact' !! 'DIFFERS');
}

# Output:
#      23 chars in ->  14 chars out   round trip exact
#      24 chars in ->  16 chars out   round trip exact
#      30 chars in ->   8 chars out   round trip exact
#       3 chars in ->   3 chars out   round trip exact
