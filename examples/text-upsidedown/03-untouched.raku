#!/usr/bin/env rakupp
# Text::UpsideDown — What it does not touch
# https://raku.online/modules/text-upsidedown/#what-it-does-not-touch
#
# Install what it needs, then run it:
#     rakupp install Text::UpsideDown
#     rakupp 03-untouched.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::UpsideDown;

say 'unmapped characters still get REVERSED, just not substituted:';
say '  ', upside_down("\c[CJK UNIFIED IDEOGRAPH-65E5]\c[CJK UNIFIED IDEOGRAPH-672C] \c[SNOWMAN]").raku;
say '';
say 'and a precomposed accented letter is one grapheme that is not in the';
say 'table, so only its position moves:';
my $acc = "e\c[COMBINING ACUTE ACCENT]f";
say '  input  : ', $acc.raku, '  (', $acc.chars, ' graphemes)';
say '  output : ', upside_down($acc).raku;
say '';
say 'newlines are characters like any other, so a multi-line string comes';
say 'back reversed across the line break:';
say '  ', upside_down("ab\ncd").raku;

# Output:
#     unmapped characters still get REVERSED, just not substituted:
#       "☃ 本日"
#     
#     and a precomposed accented letter is one grapheme that is not in the
#     table, so only its position moves:
#       input  : "éf"  (2 graphemes)
#       output : "ɟé"
#     
#     newlines are characters like any other, so a multi-line string comes
#     back reversed across the line break:
#       "pɔ\nqɐ"
