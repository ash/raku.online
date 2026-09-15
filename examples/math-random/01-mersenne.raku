#!/usr/bin/env rakupp
# Math::Random — A reproducible stream
# https://raku.online/modules/math-random/#a-reproducible-stream
#
# Install what it needs, then run it:
#     rakupp install Math::Random
#     rakupp 01-mersenne.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::Random::MT;

my $m = Math::Random::MT.mt19937;
$m.setSeed(5489);
say (^6).map({ $m.nextInt }).join(', ');

$m.setSeed(5489);
say (^6).map({ $m.nextInt }).join(', ');

my $n = Math::Random::MT.mt19937_64;
$n.setSeed(5489);
say (^3).map({ $n.nextInt }).join(', ');

my $b = Math::Random::MT.mt19937;
$b.setSeed(12345);
my @bits = (^2000).map({ $b.nextBoolean });
say 'true: ', +@bits.grep(*.so), '  false: ', +@bits.grep(!*.so);
say (^8).map({ $b.nxt(4) }).all < 16;

# Output:
#     3499211612, 581869302, 3890346734, 3586334585, 545404204, 4161255391
#     3499211612, 581869302, 3890346734, 3586334585, 545404204, 4161255391
#     3379370268, 1075804871, 3052309686
#     true: 989  false: 1011
#     all(True, True, True, True, True, True, True, True)
