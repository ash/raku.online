#!/usr/bin/env rakupp
# Math::Zeckendorf — Both representations
# https://raku.online/modules/math-zeckendorf/#both-representations
#
# Install what it needs, then run it:
#     rakupp install Math::Zeckendorf
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Zeckendorf;

for 1, 4, 12, 20, 100 -> $n {
    my @d = zeckendorf-representation($n);
    my @f = zeckendorf-representation($n, :numbers);
    say sprintf('  %3d  digits %-14s numbers %-14s sum %d',
                $n, @d.join, @f.join(','), @f.sum);
}
say '';
say 'the defining property, over 1..500:';
say '  every one reconstructs   : ',
    so (1..500).all.map({ zeckendorf-representation($_, :numbers).sum == $_ });
say '  no two adjacent 1s       : ',
    so (1..500).all.map({ !(zeckendorf-representation($_).join ~~ /11/) });

# Output:
#         1  digits 1              numbers 1              sum 1
#         4  digits 101            numbers 3,1            sum 4
#        12  digits 10101          numbers 8,3,1          sum 12
#        20  digits 101010         numbers 13,5,2         sum 20
#       100  digits 1000010100     numbers 89,8,3         sum 100
#     
#     the defining property, over 1..500:
#       every one reconstructs   : True
#       no two adjacent 1s       : True
