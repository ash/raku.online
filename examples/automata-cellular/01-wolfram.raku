#!/usr/bin/env rakupp
# Automata::Cellular — Running a rule
# https://raku.online/modules/automata-cellular/#running-a-rule
#
# Install what it needs, then run it:
#     rakupp install Automata::Cellular
#     rakupp 01-wolfram.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Automata::Cellular;

my $w = Wolfram.new(number => 30, width => 21);
say 'generation 0: ', $w.current;
for 1 .. 6 {
    $w.succ;
    say "generation $_: ", $w.current;
}

# Output:
#     generation 0: ..........X..........
#     generation 1: .........XXX.........
#     generation 2: ........XX..X........
#     generation 3: .......XX.XXXX.......
#     generation 4: ......XX..X...X......
#     generation 5: .....XX.XXXX.XXX.....
#     generation 6: ....XX..X....X..X....
