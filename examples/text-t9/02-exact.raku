#!/usr/bin/env rakupp
# Text::T9 — Looking words up
# https://raku.online/modules/text-t9/#looking-words-up
#
# Install what it needs, then run it:
#     rakupp install Text::T9
#     rakupp 02-exact.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::T9;

my @words = <good home>;
for '4663', '466', '46630', '' -> $d {
    say sprintf('  t9(%-8s) -> %s', $d.raku, t9($d, @words).List.raku);
}
say '';
say 'there is no entry for space, 0 or 1 in the table.';

# Output:
#       t9("4663"  ) -> ("good", "home")
#       t9("466"   ) -> ()
#       t9("46630" ) -> ()
#       t9(""      ) -> ()
#     
#     there is no entry for space, 0 or 1 in the table.
