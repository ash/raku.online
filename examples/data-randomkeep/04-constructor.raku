#!/usr/bin/env rakupp
# Data::RandomKeep — The constructor takes a positional
# https://raku.online/modules/data-randomkeep/#the-constructor-takes-a-positional
#
# Install what it needs, then run it:
#     rakupp install Data::RandomKeep
#     rakupp 04-constructor.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Data::RandomKeep;

say 'new(6).nb-to-keep             : ', Data::RandomKeep.new(6).nb-to-keep;
say 'new(:nb-to-keep(6)).nb-to-keep: ', Data::RandomKeep.new(nb-to-keep => 6).nb-to-keep;
say 'new().nb-to-keep              : ', Data::RandomKeep.new.nb-to-keep;
say '';
say '`new` is overridden with a POSITIONAL parameter, so the named form';
say 'lands in the implicit *%_ and is discarded. .bless(:nb-to-keep(6))';
say 'does work, which makes the failure look arbitrary — pass the';
say 'positional.';
say '';
say 'and new(0) is accepted and keeps nothing, forever, without complaint:';
my $z = Data::RandomKeep.new(0);
$z.offer(1, 2, 3);
say '  new(0): nb-seen=', $z.nb-seen, ' nb-kept=', $z.nb-kept;

# Output:
#     new(6).nb-to-keep             : 6
#     new(:nb-to-keep(6)).nb-to-keep: 1
#     new().nb-to-keep              : 1
#     
#     `new` is overridden with a POSITIONAL parameter, so the named form
#     lands in the implicit *%_ and is discarded. .bless(:nb-to-keep(6))
#     does work, which makes the failure look arbitrary — pass the
#     positional.
#     
#     and new(0) is accepted and keeps nothing, forever, without complaint:
#       new(0): nb-seen=3 nb-kept=0
