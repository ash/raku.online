#!/usr/bin/env rakupp
# Algorithm::TernarySearchTree — Where the two engines differ
# https://raku.online/modules/algorithm-ternarysearchtree/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Algorithm::TernarySearchTree
#     rakupp 04-balance.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::TernarySearchTree;
use Algorithm::TernarySearchTree::Node;

sub depth($n) { return 0 unless $n.defined; 1 + max(depth($n.lokid), depth($n.eqkid), depth($n.hikid)) }
sub chain($n) {
    return 0 unless $n.defined;
    max(1 + chain($n.lokid), 1 + chain($n.hikid), chain($n.eqkid))
}

my @letters = 'a' .. 'z';
for 'sorted', @letters.map(* ~ 'x'),
    'reversed', @letters.reverse.map(* ~ 'x'),
    'middle-out', (@letters[13 .. *], @letters[^13].reverse).flat.map(* ~ 'x')
-> $how, @keys {
    my $t = Algorithm::TernarySearchTree.new;
    $t.insert($_) for @keys;
    say sprintf('%-11s 26 keys -> depth %2d, longest lo/hi chain %2d',
        $how, depth($t.root), chain($t.root));
}

# Output:
#     sorted      26 keys -> depth 28, longest lo/hi chain 26
#     reversed    26 keys -> depth 28, longest lo/hi chain 26
#     middle-out  26 keys -> depth 16, longest lo/hi chain 14
