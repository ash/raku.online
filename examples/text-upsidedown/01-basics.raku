#!/usr/bin/env rakupp
# Text::UpsideDown — Flipping
# https://raku.online/modules/text-upsidedown/#flipping
#
# Install what it needs, then run it:
#     rakupp install Text::UpsideDown
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::UpsideDown;

for 'foo', 'Hello, World!', '0123456789' -> $s {
    say sprintf('  %-16s -> %s', $s.raku, upside_down($s));
}
say '';
say 'the string is FLIPPED first, so it is not a per-character map:';
say '  upside_down("foo") = ', upside_down('foo').raku, ' — not "ɟoo"';

# Output:
#       "foo"            -> ooɟ
#       "Hello, World!"  -> ¡pʃɹoM 'oʃʃǝH
#       "0123456789"     -> 68ㄥ954Ɛ2⇂0
#     
#     the string is FLIPPED first, so it is not a per-character map:
#       upside_down("foo") = "ooɟ" — not "ɟoo"
