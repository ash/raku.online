#!/usr/bin/env rakupp
# Text::Homoglyph — The one thing to know
# https://raku.online/modules/text-homoglyph/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::Homoglyph
#     rakupp 03-guard.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Homoglyph;

for 'a', 'ab', "\c[LATIN SMALL LETTER E WITH ACUTE]", "\c[CJK UNIFIED IDEOGRAPH-6F22]",
    "\c[CHRISTMAS TREE]", "\t" -> $c {
    my $r = try homoglyphs($c);
    say sprintf('%-28s chars=%d -> %s',
                $c.raku, $c.chars, $! ?? 'DIED' !! $r.elems ~ ' glyphs');
}
say '';
say 'the obvious loop $text.comb.map({ homoglyphs($_) }) therefore works';
say 'on ASCII and crashes on the first tab, newline or accented letter.';
say 'the guard the author wanted is a lookup, not a length.';

# Output:
#     "a"                          chars=1 -> 4 glyphs
#     "ab"                         chars=2 -> DIED
#     "é"                          chars=1 -> DIED
#     "漢"                          chars=1 -> DIED
#     "🎄"                          chars=1 -> DIED
#     "\t"                         chars=1 -> DIED
#     
#     the obvious loop $text.comb.map({ homoglyphs($_) }) therefore works
#     on ASCII and crashes on the first tab, newline or accented letter.
#     the guard the author wanted is a lookup, not a length.
