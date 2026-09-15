#!/usr/bin/env rakupp
# Data::RandomKeep — Sampling
# https://raku.online/modules/data-randomkeep/#sampling
#
# Install what it needs, then run it:
#     rakupp install Data::RandomKeep
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::RandomKeep;

my $k = Data::RandomKeep.new(3);
say 'nb-to-keep : ', $k.nb-to-keep;
$k.offer($_) for 1 .. 100;
say 'nb-seen    : ', $k.nb-seen;
say 'nb-kept    : ', $k.nb-kept;
my @kept = $k.kept;
say 'kept       : ', @kept.elems, ' items, all from 1..100 : ',
    so @kept.all ~~ 1..100;
say '  distinct : ', @kept.unique.elems == @kept.elems;
say '';
say 'offer is slurpy and flattens, so a whole list can go in at once:';
my $b = Data::RandomKeep.new(2);
$b.offer(1 .. 5);
say '  nb-seen after offer(1..5) : ', $b.nb-seen;

# Output:
#     nb-to-keep : 3
#     nb-seen    : 100
#     nb-kept    : 3
#     kept       : 3 items, all from 1..100 : True
#       distinct : True
#     
#     offer is slurpy and flattens, so a whole list can go in at once:
#       nb-seen after offer(1..5) : 5
