#!/usr/bin/env rakupp
# Grammar::DiceRolls — Rolling
# https://raku.online/modules/grammar-dicerolls/#rolling
#
# Install what it needs, then run it:
#     rakupp install Grammar::DiceRolls
#     rakupp 02-roll.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Grammar::DiceRolls;
use Grammar::DiceRolls::CountActions;
use Grammar::DiceRolls::ListActions;

my @totals = (^200).map({
    Grammar::DiceRolls.parse('3d6+2', actions => Grammar::DiceRolls::CountActions.new).made
});
say 'CountActions gives an Int  : ', ?all(@totals.map(* ~~ Int));
say '3d6+2 is always in 5..20   : ', ?all(@totals.map({ 5 <= $_ <= 20 }));
say 'and the range is exercised : ', @totals.min == 5 || @totals.unique.elems > 8;
say '';
my @lists = (^200).map({
    Grammar::DiceRolls.parse('3d6+2', actions => Grammar::DiceRolls::ListActions.new).made.List
});
say 'ListActions gives 4 values : ', ?all(@lists.map(*.elems == 4));
say 'first three are each 1..6  : ', ?all(@lists.map({ ?all(.[^3].map({ 1 <= $_ <= 6 })) }));
say 'the last is the bonus, 2   : ', ?all(@lists.map(*.[3] == 2));

# Output:
#     CountActions gives an Int  : True
#     3d6+2 is always in 5..20   : True
#     and the range is exercised : True
#     
#     ListActions gives 4 values : True
#     first three are each 1..6  : True
#     the last is the bonus, 2   : True
