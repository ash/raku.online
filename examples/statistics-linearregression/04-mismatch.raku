#!/usr/bin/env rakupp
# Statistics::LinearRegression — No length check
# https://raku.online/modules/statistics-linearregression/#no-length-check
#
# Install what it needs, then run it:
#     rakupp install Statistics::LinearRegression
#     rakupp 04-mismatch.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::LinearRegression;

say 'mismatched list lengths are NOT checked:';
say '  LR.new([1,2,3], [1,2]).get-parameters = ',
    LR.new([1, 2, 3], [1, 2]).get-parameters.raku;
say '  LR.new([1,2], [1,2,3]).get-parameters = ',
    LR.new([1, 2], [1, 2, 3]).get-parameters.raku;
say '';
say 'N comes from +@x while only min(@x, @y) cross terms exist, so you';
say 'get a silently wrong fit rather than an error. Check first:';
sub fit(@x, @y) {
    die "x has {+@x} points, y has {+@y}" unless @x.elems == @y.elems;
    LR.new(@x, @y).get-parameters
}
my $r = try fit([1, 2, 3], [1, 2]);
say '  ', $! ?? $!.message !! $r.raku;
say '';
say 'and empty lists give the same <0/0> as the degenerate case:';
say '  LR.new([], []).get-parameters = ', LR.new([], []).get-parameters.raku;

# Output:
#     mismatched list lengths are NOT checked:
#       LR.new([1,2,3], [1,2]).get-parameters = (-0.5, 2.0)
#       LR.new([1,2], [1,2,3]).get-parameters = (-8.0, 15.0)
#     
#     N comes from +@x while only min(@x, @y) cross terms exist, so you
#     get a silently wrong fit rather than an error. Check first:
#       x has 3 points, y has 2
#     
#     and empty lists give the same <0/0> as the degenerate case:
#       LR.new([], []).get-parameters = (<0/0>, <0/0>)
