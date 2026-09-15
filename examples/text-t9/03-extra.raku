#!/usr/bin/env rakupp
# Text::T9 — Extending the keypad
# https://raku.online/modules/text-t9/#extending-the-keypad
#
# Install what it needs, then run it:
#     rakupp install Text::T9
#     rakupp 03-extra.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::T9;

my @words = <good Good GOOD home>;
say 'default          : ', t9('4663', @words).List.raku;
my %extra = G => 4, O => 6, D => 3;
say 'with %additional : ', t9('4663', @words, %extra).List.raku;
say '';
say 'the third argument MERGES with the built-in table, later wins — so';
say 'it both extends (uppercase) and overrides:';
my %override = a => 1, g => 1, o => 1, d => 1;
say '  t9("1111", ["good"], %override) = ', t9('1111', ['good'], %override).List.raku;
say '';
say 'and the alias export works the same way:';
say '  t9_find_words("4663", @words) = ', t9_find_words('4663', @words).List.raku;

# Output:
#     default          : ("good", "home")
#     with %additional : ("good", "Good", "GOOD", "home")
#     
#     the third argument MERGES with the built-in table, later wins — so
#     it both extends (uppercase) and overrides:
#       t9("1111", ["good"], %override) = ("good",)
#     
#     and the alias export works the same way:
#       t9_find_words("4663", @words) = ("good", "home")
