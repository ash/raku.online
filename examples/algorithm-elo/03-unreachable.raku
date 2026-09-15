#!/usr/bin/env rakupp
# Algorithm::Elo — The one thing to know
# https://raku.online/modules/algorithm-elo/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Elo
#     rakupp 03-unreachable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::Elo;

my @messages;
for (True, False, Bool) -> $l {
    for (True, False, Bool) -> $r {
        for (True, False, Bool) -> $d {
            my %args;
            %args<left>  = $l unless $l === Bool;
            %args<right> = $r unless $r === Bool;
            %args<draw>  = $d unless $d === Bool;
            my $out = try calculate-elo(1600, 1600, |%args);
            @messages.push: $! ?? $!.message !! 'OK ' ~ $out.List.raku;
        }
    }
}
say 'all 27 flag combinations:';
for @messages.Bag.sort(*.key) -> $p { say '  ', $p.value, ' x  ', $p.key }
say '';
say 'the second guard\'s message was seen : ',
    ?@messages.first(*.contains('least one'));

# Output:
#     all 27 flag combinations:
#       15 x  :left, :right, and :draw are mutually exclusive
#       4 x  OK (1584, 1616)
#       4 x  OK (1600, 1600)
#       4 x  OK (1616, 1584)
#     
#     the second guard's message was seen : False
