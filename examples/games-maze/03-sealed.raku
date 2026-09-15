#!/usr/bin/env rakupp
# Games::Maze — The one thing to know
# https://raku.online/modules/games-maze/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Games::Maze
#     rakupp 03-sealed.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Games::Maze;

my ($h, $w) = 5, 6;
my $m = Games::Maze.new(height => $h, width => $w);
$m.make;
my @l = $m.render.lines;

sub south(Str $line) { (^$w).map({ $line.substr(1 + 2 * $_, 1) }) }
sub east(Str  $line) { (^$w).map({ $line.substr(2 + 2 * $_, 1) }) }

say 'bottom row: every south wall closed : ', ?all(south(@l[*-1]).map(* eq '_'));
say 'every row: right-hand east wall "|" : ', ?all(@l[1..*].map({ east($_)[*-1] eq '|' }));
say 'every row starts with "|"           : ', ?all(@l[1..*].map({ .substr(0,1) eq '|' }));
say 'header is all "_" separators        : ', @l[0] eq ' ' ~ ('_ ' x $w);

# Output:
#     bottom row: every south wall closed : True
#     every row: right-hand east wall "|" : True
#     every row starts with "|"           : True
#     header is all "_" separators        : True
