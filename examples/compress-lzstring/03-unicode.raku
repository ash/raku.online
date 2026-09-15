#!/usr/bin/env rakupp
# Compress::LZString — Non-ASCII
# https://raku.online/modules/compress-lzstring/#non-ascii
#
# Install what it needs, then run it:
#     rakupp install Compress::LZString
#     rakupp 03-unicode.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Compress::LZString;

for "héllo wörld", "日本語テキスト日本語テキスト", "\c[PILE OF POO]" -> $s {
    my $u = lz-compress-uri($s);
    say sprintf('%-22s -> %2d chars, round trip %s',
        $s.raku, $u.chars, lz-decompress-uri($u) eq $s ?? 'exact' !! 'DIFFERS');
}

# Output:
#     "héllo wörld"          -> 21 chars, round trip exact
#     "日本語テキスト日本語テキスト"       -> 27 chars, round trip exact
#     "💩"                    ->  7 chars, round trip exact
