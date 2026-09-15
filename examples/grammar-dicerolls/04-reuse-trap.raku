#!/usr/bin/env rakupp
# Grammar::DiceRolls — The one thing to know
# https://raku.online/modules/grammar-dicerolls/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Grammar::DiceRolls
#     rakupp 04-reuse-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Grammar::DiceRolls;
use Grammar::DiceRolls::ListActions;

my $actions = Grammar::DiceRolls::ListActions.new(limit-dice => 3);

for 1, 2 -> $n {
    my $r = try Grammar::DiceRolls.parse('2d6', actions => $actions);
    say "parse $n of the identical '2d6' : ",
        $! ?? "threw, count={$!.count}" !! "ok, {$r.made.elems} results";
}
say '';
say 'a fresh object each time works:';
for 1, 2 -> $n {
    my $r = try Grammar::DiceRolls.parse('2d6',
        actions => Grammar::DiceRolls::ListActions.new(limit-dice => 3));
    say "  parse $n : ", $! ?? 'threw' !! "ok, {$r.made.elems} results";
}

# Output:
#     parse 1 of the identical '2d6' : ok, 2 results
#     parse 2 of the identical '2d6' : threw, count=4
#     
#     a fresh object each time works:
#       parse 1 : ok, 2 results
#       parse 2 : ok, 2 results
