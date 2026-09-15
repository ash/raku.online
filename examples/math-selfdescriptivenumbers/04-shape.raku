#!/usr/bin/env rakupp
# Math::SelfDescriptiveNumbers — The return shape changes with the base
# https://raku.online/modules/math-selfdescriptivenumbers/#the-return-shape-changes-with-the-base
#
# Install what it needs, then run it:
#     rakupp install Math::SelfDescriptiveNumbers
#     rakupp 04-shape.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::SelfDescriptiveNumbers;

for 3, 4, 5, 10 -> $b {
    my $r = self-descriptive-numbers-of($b);
    say sprintf('  base %2d  type %-5s elems %d  value %s',
                $b, $r.WHAT.^name, $r.elems, $r.raku);
}
say '';
say "('21200') in Raku is a parenthesised Str, not a one-element list — so";
say 'base 4 hands you a List and every other non-empty base a bare Str.';
say 'Anything doing .[0] or .map across bases has to cope with both.';
say '';
say 'normalise it:';
sub answers(Int $b) { self-descriptive-numbers-of($b).list }
for 3, 4, 10 -> $b {
    say sprintf('  answers(%2d) = %s', $b, answers($b).raku);
}

# Output:
#       base  3  type List  elems 0  value $( )
#       base  4  type List  elems 2  value $("1210", "2020")
#       base  5  type Str   elems 1  value "21200"
#       base 10  type Str   elems 1  value "6210001000"
#     
#     ('21200') in Raku is a parenthesised Str, not a one-element list — so
#     base 4 hands you a List and every other non-empty base a bare Str.
#     Anything doing .[0] or .map across bases has to cope with both.
#     
#     normalise it:
#       answers( 3) = ()
#       answers( 4) = ("1210", "2020")
#       answers(10) = ("6210001000",)
