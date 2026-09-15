#!/usr/bin/env rakupp
# Text::Homoglyph — Where the two engines differ
# https://raku.online/modules/text-homoglyph/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Text::Homoglyph
#     rakupp 04-asymmetry.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Homoglyph;

say '0 -> O ? ', homoglyphs('0').grep('O').Bool;
say 'O -> 0 ? ', homoglyphs('O').grep('0').Bool;
say '';
say 'there is no way to reach the table itself (it is `my`-scoped inside';
say 'a package block) and no whole-string entry point. Per character is';
say 'the entire interface.';

# Output:
#     0 -> O ? True
#     O -> 0 ? False
#     
#     there is no way to reach the table itself (it is `my`-scoped inside
#     a package block) and no whole-string entry point. Per character is
#     the entire interface.
