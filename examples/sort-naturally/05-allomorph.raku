#!/usr/bin/env rakupp
# Sort::Naturally — Where the two engines differ
# https://raku.online/modules/sort-naturally/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Sort::Naturally
#     rakupp 05-allomorph.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sort::Naturally;

my @words = <100 14th 2>;
say 'element types : ', @words.map({ .WHAT.^name }).join(', ');
say '';
say 'the numeric ones are IntStr allomorphs, and cmp between two of them';
say 'is NUMERIC while cmp between an allomorph and a Str is TEXTUAL.';
say 'That makes cmp non-transitive here:';
say '  100 cmp 14th = ', ('100' cmp '14th' given @words) // '';
for @words.combinations(2) -> ($a, $b) {
    say sprintf('  %-5s cmp %-5s = %s', $a, $b, $a cmp $b);
}
say '';
say 'a non-transitive comparator lets sort return any permutation, and the';
say 'two engines do return different ones for the same input. naturally';
say 'fixes it by making the key a plain Str, which is why its output is';
say 'identical everywhere:';
say '  ', @words.sort({ .&naturally }).join(' ');

# Output:
#     element types : IntStr, Str, IntStr
#     
#     the numeric ones are IntStr allomorphs, and cmp between two of them
#     is NUMERIC while cmp between an allomorph and a Str is TEXTUAL.
#     That makes cmp non-transitive here:
#       100 cmp 14th = Less
#       100   cmp 14th  = Less
#       100   cmp 2     = More
#       14th  cmp 2     = Less
#     
#     a non-transitive comparator lets sort return any permutation, and the
#     two engines do return different ones for the same input. naturally
#     fixes it by making the key a plain Str, which is why its output is
#     identical everywhere:
#       2 14th 100
