#!/usr/bin/env rakupp
# Grammar::DiceRolls — Parsing the notation
# https://raku.online/modules/grammar-dicerolls/#parsing-the-notation
#
# Install what it needs, then run it:
#     rakupp install Grammar::DiceRolls
#     rakupp 01-parse.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Grammar::DiceRolls;

my $m = Grammar::DiceRolls.parse('3d6+2d4-1');
say 'parsed  : ', ?$m;
say 'dice    : ', $m<dice>.map({ "{$_<count>}d{$_<sides>}" }).join(' ');
say 'bonus   : ', $m<bonus>.map({ $_<value>.Str }).join(' ');
say '';
for '1d6', '1d6+2', '1d6-2', '2d6+1d4', '1d6+2-3', 'd6', '0d6', '1d0', '1 d 6', '' -> $s {
    say sprintf('parse %-10s -> %s', "'$s'", Grammar::DiceRolls.parse($s) ?? 'ok' !! 'no match');
}

# Output:
#     parsed  : True
#     dice    : 3d6 2d4
#     bonus   : -1
#     
#     parse '1d6'      -> ok
#     parse '1d6+2'    -> ok
#     parse '1d6-2'    -> ok
#     parse '2d6+1d4'  -> ok
#     parse '1d6+2-3'  -> ok
#     parse 'd6'       -> no match
#     parse '0d6'      -> ok
#     parse '1d0'      -> ok
#     parse '1 d 6'    -> no match
#     parse ''         -> no match
