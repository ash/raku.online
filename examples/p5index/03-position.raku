#!/usr/bin/env rakupp
# P5index — The position argument
# https://raku.online/modules/p5index/#the-position-argument
#
# Install what it needs, then run it:
#     rakupp install P5index
#     rakupp 03-position.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5index;

my $s = 'abcabcabc';
say 'index from a position — the search STARTS there:';
for 0, 1, 3, 4, 20, -5 -> $pos {
    say sprintf('  index($s, "abc", %3d) = %s', $pos, index($s, 'abc', $pos));
}
say '';
say 'rindex from a position — the match must START at or before it:';
for 0, 3, 5, 6, 20 -> $pos {
    say sprintf('  rindex($s, "abc", %3d) = %s', $pos, rindex($s, 'abc', $pos));
}
say '';
say 'a negative position is clamped to 0 and an out-of-range one is';
say 'clamped to the end, as in Perl — neither is an error.';

# Output:
#     index from a position — the search STARTS there:
#       index($s, "abc",   0) = 0
#       index($s, "abc",   1) = 3
#       index($s, "abc",   3) = 3
#       index($s, "abc",   4) = 6
#       index($s, "abc",  20) = -1
#       index($s, "abc",  -5) = 0
#     
#     rindex from a position — the match must START at or before it:
#       rindex($s, "abc",   0) = 0
#       rindex($s, "abc",   3) = 3
#       rindex($s, "abc",   5) = 3
#       rindex($s, "abc",   6) = 6
#       rindex($s, "abc",  20) = 6
#     
#     a negative position is clamped to 0 and an out-of-range one is
#     clamped to the end, as in Perl — neither is an error.
