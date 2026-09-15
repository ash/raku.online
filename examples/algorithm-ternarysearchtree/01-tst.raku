#!/usr/bin/env rakupp
# Algorithm::TernarySearchTree — Storing and finding
# https://raku.online/modules/algorithm-ternarysearchtree/#storing-and-finding
#
# Install what it needs, then run it:
#     rakupp install Algorithm::TernarySearchTree
#     rakupp 01-tst.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::TernarySearchTree;

my $t = Algorithm::TernarySearchTree.new;
$t.insert($_) for <cat cats car card care dog do doge>;

for <cat cats ca card do dog doge dogs x> -> $k {
    say sprintf('contains(%-6s) = %s', "'$k'", $t.contains($k));
}

# Output:
#     contains('cat' ) = True
#     contains('cats') = True
#     contains('ca'  ) = False
#     contains('card') = True
#     contains('do'  ) = True
#     contains('dog' ) = True
#     contains('doge') = True
#     contains('dogs') = False
#     contains('x'   ) = False
