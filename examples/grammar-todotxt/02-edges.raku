#!/usr/bin/env rakupp
# Grammar::TodoTxt — What it accepts
# https://raku.online/modules/grammar-todotxt/#what-it-accepts
#
# Install what it needs, then run it:
#     rakupp install Grammar::TodoTxt
#     rakupp 02-edges.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Grammar::TodoTxt;

for "", "\n", "   \n", "(A)\n", "x\n", "just some words\n" -> $s {
    say sprintf('parse %-12s -> %s', $s.raku,
        Grammar::TodoTxt.parse($s) ?? 'ok' !! 'no match');
}

# Output:
#     parse ""           -> no match
#     parse "\n"         -> ok
#     parse "   \n"      -> no match
#     parse "(A)\n"      -> ok
#     parse "x\n"        -> ok
#     parse "just some words\n" -> ok
