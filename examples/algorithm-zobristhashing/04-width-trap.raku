#!/usr/bin/env rakupp
# Algorithm::ZobristHashing — The one thing to know
# https://raku.online/modules/algorithm-zobristhashing/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Algorithm::ZobristHashing
#     rakupp 04-width-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::ZobristHashing;

my $z = Algorithm::ZobristHashing.new;               # default rand-max = 1e9
my @h = (^500).map({ $z.encode([$_, 'x', $_ * 7]) });
say 'default rand-max 1e9';
say '  widest hash seen over 500 inputs : ', @h.map(*.base(2).chars).max, ' bits';
say '  any hash >= 2**30                : ', ?@h.grep(* >= 2**30);

my $w = Algorithm::ZobristHashing.new(rand-max => 2**64);
my @w = (^500).map({ $w.encode([$_, 'x', $_ * 7]) });
say '';
say 'rand-max => 2**64';
say '  widest hash seen over 500 inputs : ', @w.map(*.base(2).chars).max, ' bits';
say '';
say '2**30 is ', 2**30, ', so the birthday bound is around ', (2**30).sqrt.round;

# Output:
#     default rand-max 1e9
#       widest hash seen over 500 inputs : 30 bits
#       any hash >= 2**30                : False
#     
#     rand-max => 2**64
#       widest hash seen over 500 inputs : 64 bits
#     
#     2**30 is 1073741824, so the birthday bound is around 32768
