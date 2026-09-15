#!/usr/bin/env rakupp
# Text::T9 — Where the two engines differ
# https://raku.online/modules/text-t9/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Text::T9
#     rakupp 05-warnings.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::T9;

my @words = <good home 4get>;
say 'matches : ', t9('4663', @words).List.join(' ');
say '';
say 'one more difference, in diagnostics rather than results: under Rakudo';
say 'this module prints a "Use of Nil in string context" warning to stderr';
say 'for every unmapped character it meets — 24 of them for the list above.';
say 'Raku++ prints none. The answers are identical either way, so filter';
say 'your word list to lowercase a..z if the noise matters.';
say '';
say '  filtered : ', t9('4663', @words.grep({ /^ <[a..z]>+ $/ })).List.join(' ');

# Output:
#     matches : good home
#     
#     one more difference, in diagnostics rather than results: under Rakudo
#     this module prints a "Use of Nil in string context" warning to stderr
#     for every unmapped character it meets — 24 of them for the list above.
#     Raku++ prints none. The answers are identical either way, so filter
#     your word list to lowercase a..z if the noise matters.
#     
#       filtered : good home
