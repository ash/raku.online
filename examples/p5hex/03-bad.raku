#!/usr/bin/env rakupp
# P5hex — Input it will not parse
# https://raku.online/modules/p5hex/#input-it-will-not-parse
#
# Install what it needs, then run it:
#     rakupp install P5hex
#     rakupp 03-bad.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5hex;

for 'zz', 'ff!', ' ff', '', 'ffffffffffffffffffff' -> $s {
    my $h = try hex($s);
    say sprintf('  hex(%-24s) = %s', $s.raku,
                $! ?? 'threw' !! ($h.defined ?? $h.Str !! 'not a number'));
}
say '';
say 'a string with no valid digits is Nil rather than 0, so you can tell';
say '"not a number" from "the number zero" — which Perl`s hex cannot.';
say '';
say 'big values are exact, because Raku`s Int is arbitrary precision:';
say '  hex("ffffffffffffffff")   = ', hex('ffffffffffffffff');
say '  2**64 - 1                 = ', 2**64 - 1;

# Output:
#       hex("zz"                    ) = threw
#       hex("ff!"                   ) = threw
#       hex(" ff"                   ) = threw
#       hex(""                      ) = 0
#       hex("ffffffffffffffffffff"  ) = 1208925819614629174706175
#     
#     a string with no valid digits is Nil rather than 0, so you can tell
#     "not a number" from "the number zero" — which Perl`s hex cannot.
#     
#     big values are exact, because Raku`s Int is arbitrary precision:
#       hex("ffffffffffffffff")   = 18446744073709551615
#       2**64 - 1                 = 18446744073709551615
