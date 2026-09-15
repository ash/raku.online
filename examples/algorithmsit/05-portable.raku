#!/usr/bin/env rakupp
# AlgorithmsIT — Where the two engines differ
# https://raku.online/modules/algorithmsit/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install AlgorithmsIT
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use AlgorithmsIT :p1005, :p1006;
use AlgorithmsIT::Classes;

# always wrap the arguments, and always read the result as a slice
sub kmp(Str $text, Str $pattern) {
    KMP-Matcher(ArrayOneBased.new($text), ArrayOneBased.new($pattern)).List
}
say 'kmp("abababacaba", "ababaca") = ', kmp('abababacaba', 'ababaca').raku;
say '';
say 'two edges to guard against, identical on both engines:';
say '  an EMPTY pattern returns the spurious shift [1]:';
say '    ', kmp('abc', '').raku;
say '  and Compute-Prefix-Function on an empty pattern returns [0]:';
say '    ', Compute-Prefix-Function(ArrayOneBased.new('')).gist;
say '';
say 'the matcher compares with eq/ne, so elements compare as STRINGS —';
say '2.0 matches 2 and "01" does not match 1. For text that is exactly';
say 'what you want; for numeric data it is not.';

# Output:
#     kmp("abababacaba", "ababaca") = (2,)
#     
#     two edges to guard against, identical on both engines:
#       an EMPTY pattern returns the spurious shift [1]:
#         (1,)
#       and Compute-Prefix-Function on an empty pattern returns [0]:
#         [ 0 ]
#     
#     the matcher compares with eq/ne, so elements compare as STRINGS —
#     2.0 matches 2 and "01" does not match 1. For text that is exactly
#     what you want; for numeric data it is not.
