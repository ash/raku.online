#!/usr/bin/env rakupp
# Grammar::DiceRolls — Limits
# https://raku.online/modules/grammar-dicerolls/#limits
#
# Install what it needs, then run it:
#     rakupp install Grammar::DiceRolls
#     rakupp 03-limits.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Grammar::DiceRolls;
use Grammar::DiceRolls::ListActions;
use X::Grammar::DiceRolls::TooManyDice;
use X::Grammar::DiceRolls::TooManySides;

sub roll($expr, *%limits) {
    my $a = Grammar::DiceRolls::ListActions.new(|%limits);
    my $r = try Grammar::DiceRolls.parse($expr, actions => $a);
    $! ?? "{$!.^name.subst('X::Grammar::DiceRolls::', '')} count={$!.count}"
       !! "ok, {$r.made.elems} results"
}

say '2d6  with limit-dice 2   : ', roll('2d6',   :limit-dice(2));
say '3d6  with limit-dice 2   : ', roll('3d6',   :limit-dice(2));
say '1d20 with limit-sides 6  : ', roll('1d20',  :limit-sides(6));
say '2d6+1 with limit-dice 2  : ', roll('2d6+1', :limit-dice(2));

# Output:
#     2d6  with limit-dice 2   : ok, 2 results
#     3d6  with limit-dice 2   : TooManyDice count=3
#     1d20 with limit-sides 6  : TooManySides count=20
#     2d6+1 with limit-dice 2  : TooManyDice count=3
