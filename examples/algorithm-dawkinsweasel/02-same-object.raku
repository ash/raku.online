#!/usr/bin/env rakupp
# Algorithm::DawkinsWeasel — The one thing to know
# https://raku.online/modules/algorithm-dawkinsweasel/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Algorithm::DawkinsWeasel
#     rakupp 02-same-object.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::DawkinsWeasel;

my $w = Algorithm::DawkinsWeasel.new(target-phrase => 'WEASEL', copies => 30);
my @steps = $w.evolution.list;
say 'steps yielded            : ', @steps.elems > 0;
say 'every step is the SAME object : ', so @steps.all === $w;
say 'distinct phrases observed     : engine-dependent, and that is the point';
say '';
say 'so what the caller sees depends entirely on WHEN the producer ran.';
say 'On Rakudo the gather is lazy and you watch the search happen; on';
say 'Raku++ it runs eagerly in blocks of 64 takes before the first pull,';
say 'so you see the finished answer repeated N times.';
say '';
say 'the module`s whole purpose — watching cumulative selection converge —';
say 'therefore produces nothing to watch on one of the two engines.';
say '';
say 'snapshot it yourself if you want the history:';
my $v = Algorithm::DawkinsWeasel.new(target-phrase => 'WEASEL', copies => 30);
my @history;
for $v.evolution -> $step { @history.push($step.current-phrase) }
say '  the copied history is non-empty        : ', @history.elems > 0;
say '  every entry is a 6-character phrase    : ',
    so @history.all.map(*.chars == 6);
say '  the object itself ends solved          : ',
    $v.current-phrase eq 'WEASEL';

# Output:
#     steps yielded            : True
#     every step is the SAME object : True
#     distinct phrases observed     : engine-dependent, and that is the point
#     
#     so what the caller sees depends entirely on WHEN the producer ran.
#     On Rakudo the gather is lazy and you watch the search happen; on
#     Raku++ it runs eagerly in blocks of 64 takes before the first pull,
#     so you see the finished answer repeated N times.
#     
#     the module`s whole purpose — watching cumulative selection converge —
#     therefore produces nothing to watch on one of the two engines.
#     
#     snapshot it yourself if you want the history:
#       the copied history is non-empty        : True
#       every entry is a 6-character phrase    : True
#       the object itself ends solved          : True
