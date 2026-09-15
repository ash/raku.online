#!/usr/bin/env rakupp
# TrigPi — Where the two engines differ
# https://raku.online/modules/trigpi/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install TrigPi
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TrigPi;

say 'guard both at the call site:';
sub cot-pi($x) {
    my $s = sinPi($x);
    die "cot(pi*$x) is undefined" if $s == 0;
    cosPi($x) / $s
}
for 1/4, 1 -> $x {
    my $r = try cot-pi($x);
    say sprintf('  cot-pi(%-4s) -> %s', $x, $! ?? $!.message !! $r.round(0.0001));
}
say '';
sub safe-sinPi($x) {
    die "sinPi needs a finite argument" unless $x.defined && $x != Inf && $x != -Inf && $x == $x;
    sinPi($x)
}
for 0.25, NaN -> $x {
    my $r = try safe-sinPi($x);
    say sprintf('  safe-sinPi(%-5s) -> %s', $x, $! ?? 'refused' !! $r.round(0.0001));
}
say '';
say 'without those two guards, the same program raises on one engine and';
say 'hangs or answers Inf on the other.';

# Output:
#     guard both at the call site:
#       cot-pi(0.25) -> 1
#       cot-pi(1   ) -> cot(pi*1) is undefined
#     
#       safe-sinPi(0.25 ) -> 0.7071
#       safe-sinPi(NaN  ) -> refused
#     
#     without those two guards, the same program raises on one engine and
#     hangs or answers Inf on the other.
