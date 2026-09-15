#!/usr/bin/env rakupp
# Compress::LZString — When it is worth using
# https://raku.online/modules/compress-lzstring/#when-it-is-worth-using
#
# Install what it needs, then run it:
#     rakupp install Compress::LZString
#     rakupp 02-growth.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Compress::LZString;

for '', 'a', 'ab', 'hello', 'hello world',
    'the quick brown fox ' x 10 -> $s {
    my $u = lz-compress-uri($s);
    say sprintf('%-6d chars in -> %-6d chars out   %s',
        $s.chars, $u.chars, $u.chars < $s.chars ?? 'smaller' !! 'larger');
}

# Output:
#     0      chars in -> 1      chars out   larger
#     1      chars in -> 3      chars out   larger
#     2      chars in -> 5      chars out   larger
#     5      chars in -> 9      chars out   larger
#     11     chars in -> 19     chars out   larger
#     200    chars in -> 104    chars out   smaller
