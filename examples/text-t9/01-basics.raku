#!/usr/bin/env rakupp
# Text::T9 — Looking words up
# https://raku.online/modules/text-t9/#looking-words-up
#
# Install what it needs, then run it:
#     rakupp install Text::T9
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::T9;

my @words = <good home gone hood hone goof book cook Good HOME re-do 4get>;
say 't9("4663", @words) : ', t9('4663', @words).List.raku;
say 't9(4663, @words)   : ', t9(4663, @words).List.raku, '   <- Str(Int) coercion';
say 't9("2665", @words) : ', t9('2665', @words).List.raku;
say '';
say 'the return type is ', t9('4663', @words).WHAT.^name;
say '';
say 'Good, HOME, re-do and 4get never match — only lowercase a..z are in';
say 'the keypad table, and an unmapped character silently makes the whole';
say 'word unmatchable rather than raising.';

# Output:
#     t9("4663", @words) : ("good", "home", "gone", "hood", "hone", "goof")
#     t9(4663, @words)   : ("good", "home", "gone", "hood", "hone", "goof")   <- Str(Int) coercion
#     t9("2665", @words) : ("book", "cook")
#     
#     the return type is Seq
#     
#     Good, HOME, re-do and 4get never match — only lowercase a..z are in
#     the keypad table, and an unmapped character silently makes the whole
#     word unmatchable rather than raising.
