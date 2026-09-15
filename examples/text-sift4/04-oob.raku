#!/usr/bin/env rakupp
# Text::Sift4 — Where the two engines differ
# https://raku.online/modules/text-sift4/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Text::Sift4
#     rakupp 04-oob.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Sift4;

# same-length inputs never reach the unguarded substr
for <abcd abcd>, <abcd abdc>, <abcd wxyz> -> ($x, $y) {
    say sprintf('sift4(%-6s, %-6s) = %d', $x.raku, $y.raku, sift4($x, $y));
}
say '';
say 'those are safe on both engines. A pair whose lengths differ can walk';
say 'the left cursor past the end of its string, and what happens then is';
say 'up to the engine — so wrap every call you cannot length-match.';

# Output:
#     sift4("abcd", "abcd") = 0
#     sift4("abcd", "abdc") = 1
#     sift4("abcd", "wxyz") = 4
#     
#     those are safe on both engines. A pair whose lengths differ can walk
#     the left cursor past the end of its string, and what happens then is
#     up to the engine — so wrap every call you cannot length-match.
