#!/usr/bin/env rakupp
# Statistics::LinearRegression — Fitting
# https://raku.online/modules/statistics-linearregression/#fitting
#
# Install what it needs, then run it:
#     rakupp install Statistics::LinearRegression
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::LinearRegression;

my @x = 1, 2, 3, 4, 5, 6;
my @y = 2, 4, 5, 4, 5, 7;

my $lr = LR.new(@x, @y);
my ($slope, $intercept) = $lr.get-parameters;
say 'slope      : ', $slope, '   (', $slope.WHAT.^name, ')';
say 'intercept  : ', $intercept;
say 'at x = 10  : ', $lr.at(10);
say '';
my $sx  = @x.sum;
my $sy  = @y.sum;
my $sxy = (@x Z* @y).sum;
my $sxx = (@x Z* @x).sum;
my $n   = @x.elems;
my $closed = ($n * $sxy - $sx * $sy) / ($n * $sxx - $sx * $sx);
say 'closed form: ', $closed;
say 'matches    : ', $slope == $closed;
say '';
say 'results are exact Rats, not Nums, when the inputs are integers.';

# Output:
#     slope      : 0.771429   (Rat)
#     intercept  : 1.8
#     at x = 10  : 9.514286
#     
#     closed form: 0.771429
#     matches    : True
#     
#     results are exact Rats, not Nums, when the inputs are integers.
