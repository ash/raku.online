#!/usr/bin/env rakupp
# Statistics::LinearRegression — Where the two engines differ
# https://raku.online/modules/statistics-linearregression/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Statistics::LinearRegression
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::LinearRegression;

# a fit that reports what it did, and refuses what it cannot do
sub regress(@x, @y) {
    die "x has {+@x} points, y has {+@y}" unless @x.elems == @y.elems;
    die 'need at least two points'        unless @x.elems >= 2;
    my $lr = LR.new(@x, @y);
    my ($m, $b) = $lr.get-parameters;
    die 'the x values do not vary'        if $m.denominator == 0;
    %( slope => $m, intercept => $b, predict => -> $x { $lr.at($x) } )
}
my %f = regress([1, 2, 3, 4], [2, 4, 6, 8]);
say 'slope     : ', %f<slope>;
say 'intercept : ', %f<intercept>;
say 'predict 10: ', %f<predict>(10);
say '';
say 'the class`s full name is Statistics::LinearRegression::LR; `LR` is';
say 'what a plain `use` exports it as.';

# Output:
#     slope     : 2
#     intercept : 0
#     predict 10: 20
#     
#     the class`s full name is Statistics::LinearRegression::LR; `LR` is
#     what a plain `use` exports it as.
