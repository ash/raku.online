#!/usr/bin/env rakupp
# Data::RandomKeep — Uniformity
# https://raku.online/modules/data-randomkeep/#uniformity
#
# Install what it needs, then run it:
#     rakupp install Data::RandomKeep
#     rakupp 02-uniform.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::RandomKeep;

my %count;
my $trials = 20_000;
for ^$trials {
    my $k = Data::RandomKeep.new(1);
    $k.offer($_) for ^20;
    %count{$k.kept[0]}++;
}
say "keep 1 of 20, $trials trials";
say '  distinct items ever kept : ', %count.keys.elems;
my $expected = $trials / 20;
my $sigma = sqrt($expected * 19 / 20);
say '  expected per item        : ', $expected.Int;
say '  every count within 5 sigma : ',
    so %count.values.all ~~ ($expected - 5 * $sigma) .. ($expected + 5 * $sigma);
say '  total kept == trials     : ', %count.values.sum == $trials;

# Output:
#     keep 1 of 20, 20000 trials
#       distinct items ever kept : 20
#       expected per item        : 1000
#       every count within 5 sigma : True
#       total kept == trials     : True
