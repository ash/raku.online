#!/usr/bin/env rakupp
# Math::Zeckendorf — Where the two engines differ
# https://raku.online/modules/math-zeckendorf/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Math::Zeckendorf
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Zeckendorf;

# coerce at the call site and the two agree
sub zeck($n) {
    my $i = $n.Int;
    die "zeckendorf needs a positive integer, got $n" unless $i > 0;
    zeckendorf-representation($i, :numbers)
}
for 12, 12.0, 0 -> $n {
    my $r = try zeck($n);
    say sprintf('  zeck(%-5s) -> %s', $n.raku, $! ?? $!.message !! $r.join(','));
}
say '';
say 'the class Math::Zeckendorf itself is an empty shell — the two protos';
say 'and their aliases are the whole distribution.';

# Output:
#       zeck(12   ) -> 8,3,1
#       zeck(12.0 ) -> 8,3,1
#       zeck(0    ) -> zeckendorf needs a positive integer, got 0
#     
#     the class Math::Zeckendorf itself is an empty shell — the two protos
#     and their aliases are the whole distribution.
