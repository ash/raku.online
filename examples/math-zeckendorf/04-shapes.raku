#!/usr/bin/env rakupp
# Math::Zeckendorf — Two shapes to know
# https://raku.online/modules/math-zeckendorf/#two-shapes-to-know
#
# Install what it needs, then run it:
#     rakupp install Math::Zeckendorf
#     rakupp 04-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Zeckendorf;

say 'the two functions return different ELEMENT types:';
my @z = zeckendorf-representation(12);
my @d = dual-zeckendorf-representation(12);
say '  zeckendorf      : ', @z.raku, '  element type ', @z[0].WHAT.^name;
say '  dual            : ', @d.raku, '  element type ', @d[0].WHAT.^name;
say '  @z eqv @d       : ', (@z eqv @d), '   <- never true, even for equal digits';
say '  joined          : ', @z.join.raku, ' vs ', @d.join.raku;
say '';
say 'the dual builds a string and .combs it; the primary pushes Ints.';
say '.join hides the difference; eqv, == and any numeric use do not.';
say '';
say 'and zero and negatives return an empty array, not [0] and not a';
say 'failure:';
for 0, -5 -> $n {
    say sprintf('  %3d -> %s', $n, zeckendorf-representation($n).raku);
}
say '';
say 'the two aliases `zeckendorf` and `dual-zeckendorf` ARE importable,';
say 'though introspection tools tend not to list them:';
say '  zeckendorf(12)      = ', zeckendorf(12).join;
say '  dual-zeckendorf(12) = ', dual-zeckendorf(12).join;

# Output:
#     the two functions return different ELEMENT types:
#       zeckendorf      : [1, 0, 1, 0, 1]  element type Int
#       dual            : ["1", "0", "1", "0", "1"]  element type Str
#       @z eqv @d       : False   <- never true, even for equal digits
#       joined          : "10101" vs "10101"
#     
#     the dual builds a string and .combs it; the primary pushes Ints.
#     .join hides the difference; eqv, == and any numeric use do not.
#     
#     and zero and negatives return an empty array, not [0] and not a
#     failure:
#         0 -> []
#        -5 -> []
#     
#     the two aliases `zeckendorf` and `dual-zeckendorf` ARE importable,
#     though introspection tools tend not to list them:
#       zeckendorf(12)      = 10101
#       dual-zeckendorf(12) = 10101
