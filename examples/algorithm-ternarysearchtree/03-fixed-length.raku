#!/usr/bin/env rakupp
# Algorithm::TernarySearchTree — The one thing to know
# https://raku.online/modules/algorithm-ternarysearchtree/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Algorithm::TernarySearchTree
#     rakupp 03-fixed-length.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::TernarySearchTree;

my $t = Algorithm::TernarySearchTree.new;
$t.insert($_) for <do dog doge dogs>;

for 'do', 'do.', 'do..', 'd...' -> $p {
    say sprintf('%-7s -> {%s}', "'$p'", $t.partial-match($p).keys.sort.join(' '));
}
say '';
say 'there is no single pattern that returns all four:';
say '  you must ask per length, or keep your own prefix index';
for 2 .. 4 -> $n {
    say sprintf('  length %d : {%s}', $n,
        $t.partial-match('.' x $n).keys.sort.join(' '));
}

# Output:
#     'do'    -> {do}
#     'do.'   -> {dog}
#     'do..'  -> {doge dogs}
#     'd...'  -> {doge dogs}
#     
#     there is no single pattern that returns all four:
#       you must ask per length, or keep your own prefix index
#       length 2 : {do}
#       length 3 : {dog}
#       length 4 : {doge dogs}
