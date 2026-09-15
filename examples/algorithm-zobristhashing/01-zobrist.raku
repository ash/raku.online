#!/usr/bin/env rakupp
# Algorithm::ZobristHashing — Hashing a board
# https://raku.online/modules/algorithm-zobristhashing/#hashing-a-board
#
# Install what it needs, then run it:
#     rakupp install Algorithm::ZobristHashing
#     rakupp 01-zobrist.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::ZobristHashing;

my $z = Algorithm::ZobristHashing.new;

my $h = $z.encode('abc');
my $x = $z.get(0, 'a') +^ $z.get(1, 'b') +^ $z.get(2, 'c');
say 'a hash is the XOR of its per-(position,piece) keys : ', $h == $x;

say 'stable within one instance    : ', $z.encode('abc') == $z.encode('abc');
say 'different across instances    : ',
    Algorithm::ZobristHashing.new.encode('abc') != Algorithm::ZobristHashing.new.encode('abc');
say 'position matters, not just content : ', $z.encode('ab') != $z.encode('ba');

# Output:
#     a hash is the XOR of its per-(position,piece) keys : True
#     stable within one instance    : True
#     different across instances    : True
#     position matters, not just content : True
