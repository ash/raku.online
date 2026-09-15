#!/usr/bin/env rakupp
# Algorithm::LCS — Choosing how elements compare
# https://raku.online/modules/algorithm-lcs/#choosing-how-elements-compare
#
# Install what it needs, then run it:
#     rakupp install Algorithm::LCS
#     rakupp 02-compare.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::LCS;

say 'default comparator is eqv, which is type-strict:';
say '  lcs([1,2,3], ["1","2","3"])              = ', lcs([1,2,3], ['1','2','3']).List.raku;
say '  with :compare(&infix:<eq>)               = ',
    lcs([1,2,3], ['1','2','3'], compare => &infix:<eq>).List.raku;
say '  lcs([1.0, 2.0], [1, 2]) — Rat versus Int = ', lcs([1.0, 2.0], [1, 2]).List.raku;
say '';
say ':compare-i sees indices into the ORIGINAL arrays:';
my @a = <q a b z>;
my @b = <q a c z>;
my @seen;
my @res = lcs(@a, @b, compare-i => -> $i, $j { @seen.push("($i,$j)"); @a[$i] eq @b[$j] });
say '  result      : ', @res.List.raku;
say '  index pairs : ', @seen.join(' ');

# Output:
#     default comparator is eqv, which is type-strict:
#       lcs([1,2,3], ["1","2","3"])              = ()
#       with :compare(&infix:<eq>)               = (1, 2, 3)
#       lcs([1.0, 2.0], [1, 2]) — Rat versus Int = ()
#     
#     :compare-i sees indices into the ORIGINAL arrays:
#       result      : ("q", "a", "z")
#       index pairs : (0,0) (1,1) (2,2) (3,3) (2,2) (2,2)
