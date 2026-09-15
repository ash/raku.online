#!/usr/bin/env rakupp
# Math::Zeckendorf — Both representations
# https://raku.online/modules/math-zeckendorf/#both-representations
#
# Install what it needs, then run it:
#     rakupp install Math::Zeckendorf
#     rakupp 02-dual.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Zeckendorf;

for 11, 19, 20 -> $n {
    my @d = dual-zeckendorf-representation($n);
    my @f = dual-zeckendorf-representation($n, :numbers);
    say sprintf('  %3d  digits %-12s numbers %-14s sum %d',
                $n, @d.join, @f.join(','), @f.sum);
}
say '';
say '  every one reconstructs   : ',
    so (1..500).all.map({ dual-zeckendorf-representation($_, :numbers).sum == $_ });
say '  no two adjacent 0s inside: ',
    so (1..500).all.map({ !(dual-zeckendorf-representation($_).join ~~ /00/) });
say '';
say 'big inputs are fine:';
my @big = zeckendorf-representation(10**30, :numbers);
say '  10**30 needs ', zeckendorf-representation(10**30).elems, ' digits';
say '  and its numbers sum back exactly : ', @big.sum == 10**30;

# Output:
#        11  digits 1111         numbers 5,3,2,1        sum 11
#        19  digits 11111        numbers 8,5,3,2,1      sum 19
#        20  digits 101010       numbers 13,5,2         sum 20
#     
#       every one reconstructs   : True
#       no two adjacent 0s inside: True
#     
#     big inputs are fine:
#       10**30 needs 144 digits
#       and its numbers sum back exactly : True
