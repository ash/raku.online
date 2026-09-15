#!/usr/bin/env rakupp
# Statistics::LinearRegression — The one thing to know
# https://raku.online/modules/statistics-linearregression/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Statistics::LinearRegression
#     rakupp 03-degenerate.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Statistics::LinearRegression;

my ($slope, $intercept) = LR.new([2, 2, 2], [1, 2, 3]).get-parameters;
say 'all x equal:';
say '  .WHAT        : ', $slope.WHAT.^name;
say '  .defined     : ', $slope.defined;
say '  .denominator : ', $slope.denominator;
say '  == 0         : ', $slope == 0;
say '  .Num         : ', $slope.Num;
my $s = try $slope.Str;
say '  .Str         : ', $! ?? 'throws X::Numeric::DivideByZero' !! $s;
say '';
say 'so `if $slope.defined { … }` passes, the bad value propagates through';
say '.at() unchanged, and the program dies at whatever line first PRINTS';
say 'it. Guard on the denominator:';
sub fit(@x, @y) {
    my ($m, $b) = LR.new(@x, @y).get-parameters;
    die 'degenerate fit: the x values do not vary' if $m.denominator == 0;
    ($m, $b)
}
for ([1, 2, 3], [3, 2, 1]), ([2, 2, 2], [1, 2, 3]) -> (@x, @y) {
    my $r = try fit(@x, @y);
    say sprintf('  fit(%-12s) -> %s', @x.raku, $! ?? $!.message !! $r.raku);
}

# Output:
#     all x equal:
#       .WHAT        : Rat
#       .defined     : True
#       .denominator : 0
#       == 0         : False
#       .Num         : NaN
#       .Str         : throws X::Numeric::DivideByZero
#     
#     so `if $slope.defined { … }` passes, the bad value propagates through
#     .at() unchanged, and the program dies at whatever line first PRINTS
#     it. Guard on the denominator:
#       fit([1, 2, 3]   ) -> $(-1.0, 4.0)
#       fit([2, 2, 2]   ) -> degenerate fit: the x values do not vary
