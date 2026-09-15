#!/usr/bin/env rakupp
# Algorithm::LCS — The one thing to know
# https://raku.online/modules/algorithm-lcs/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Algorithm::LCS
#     rakupp 03-asymmetry.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::LCS;

sub words(@alpha, $maxlen) {
    my @w; my @cur = '';
    for 1 .. $maxlen { @cur = (@cur X @alpha).map(*.join); @w.append: @cur }
    @w
}

my @w = words(<a b c>, 4);
my ($n, $lendiff, $seqdiff) = 0, 0, 0;
my @examples;
for @w -> $x {
    for @w -> $y {
        my $ab = lcs($x.comb.Array, $y.comb.Array, compare => &infix:<eq>).join;
        my $ba = lcs($y.comb.Array, $x.comb.Array, compare => &infix:<eq>).join;
        $n++;
        $lendiff++ if $ab.chars != $ba.chars;
        if $ab ne $ba {
            $seqdiff++;
            @examples.push("lcs('$x','$y')='$ab'  but  lcs('$y','$x')='$ba'") if @examples < 3;
        }
    }
}
say "ordered pairs checked           : $n";
say "length differs when swapped     : $lendiff";
say "chosen subsequence differs      : $seqdiff";
say '';
.say for @examples;

# Output:
#     ordered pairs checked           : 14400
#     length differs when swapped     : 0
#     chosen subsequence differs      : 3006
#     
#     lcs('ab','ba')='b'  but  lcs('ba','ab')='a'
#     lcs('ab','baa')='b'  but  lcs('baa','ab')='a'
#     lcs('ab','bac')='b'  but  lcs('bac','ab')='a'
