#!/usr/bin/env rakupp
# Algorithm::TernarySearchTree — The wildcard match
# https://raku.online/modules/algorithm-ternarysearchtree/#the-wildcard-match
#
# Install what it needs, then run it:
#     rakupp install Algorithm::TernarySearchTree
#     rakupp 02-partial.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::TernarySearchTree;

my $t = Algorithm::TernarySearchTree.new;
$t.insert($_) for <cat cats car card care dog do doge>;

for 'ca.', 'c..', '...', 'do.', 'do', 'cat', 'ca.s', '....' -> $p {
    say sprintf('partial-match(%-6s) -> {%s}', "'$p'",
        $t.partial-match($p).keys.sort.join(' '));
}
say '';
say 'return type : ', $t.partial-match('ca.').^name;

# Output:
#     partial-match('ca.' ) -> {car cat}
#     partial-match('c..' ) -> {car cat}
#     partial-match('...' ) -> {car cat dog}
#     partial-match('do.' ) -> {dog}
#     partial-match('do'  ) -> {do}
#     partial-match('cat' ) -> {cat}
#     partial-match('ca.s') -> {cats}
#     partial-match('....') -> {card care cats doge}
#     
#     return type : Set
