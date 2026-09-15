#!/usr/bin/env rakupp
# Text::Homoglyph — The whole API
# https://raku.online/modules/text-homoglyph/#the-whole-api
#
# Install what it needs, then run it:
#     rakupp install Text::Homoglyph
#     rakupp 01-lookup.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Homoglyph;

my @g = homoglyphs('a');
say 'homoglyphs("a") returns : ', @g.elems, ' elements';
say 'codepoints              : ', @g.map({ 'U+' ~ .ord.base(16).fmt('%04s') }).join(' ');
say 'names                   : ', @g[1..*].map(*.uniname).join(' | ');
say '';
say 'the first element is the INPUT itself, so .pick returns the';
say 'original character about one time in four.';

# Output:
#     homoglyphs("a") returns : 4 elements
#     codepoints              : U+0061 U+0251 U+0430 U+1972
#     names                   : LATIN SMALL LETTER ALPHA | CYRILLIC SMALL LETTER A | TAI LE LETTER TONE-4
#     
#     the first element is the INPUT itself, so .pick returns the
#     original character about one time in four.
