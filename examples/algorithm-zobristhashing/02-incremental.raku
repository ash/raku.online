#!/usr/bin/env rakupp
# Algorithm::ZobristHashing — The incremental update
# https://raku.online/modules/algorithm-zobristhashing/#the-incremental-update
#
# Install what it needs, then run it:
#     rakupp install Algorithm::ZobristHashing
#     rakupp 02-incremental.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::ZobristHashing;

my $z = Algorithm::ZobristHashing.new;

my @board = <r n b q k b n r>;
my $before = $z.encode(@board);

my @after = @board.clone;
@after[3] = 'Q';

my $incremental = $before +^ $z.get(3, 'q') +^ $z.get(3, 'Q');

say 'full rehash of the new board equals the incremental update : ',
    $z.encode(@after) == $incremental;

# Output:
#     full rehash of the new board equals the incremental update : True
