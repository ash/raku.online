#!/usr/bin/env rakupp
# sortuk — Prefixes are not ordered
# https://raku.online/modules/sortuk/#prefixes-are-not-ordered
#
# Install what it needs, then run it:
#     rakupp install sortuk
#     rakupp 04-prefix.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use SortUk;

say 'the inner comparison loop stops at min(chars) and, finding no';
say 'difference, falls through without deciding:';
for ['банан', 'ба'], ['ба', 'банан'] -> @in {
    say sprintf('  input %-16s -> %s', @in.join(','), sortuk(@in).join(','));
}
say '';
say 'same data, other input order, other answer. It is not a total order.';
say '';
say 'and an empty string in the list is a landmine — sortuk([""]) reads';
say 'past the end of the array and calls .lc on it, which dies on both';
say 'engines. Filter empties out first:';
my @in = ('', 'абв', 'банан');
say '  filtered : ', sortuk(@in.grep(*.chars)).join(' ');

# Output:
#     the inner comparison loop stops at min(chars) and, finding no
#     difference, falls through without deciding:
#       input банан,ба         -> банан,ба
#       input ба,банан         -> ба,банан
#     
#     same data, other input order, other answer. It is not a total order.
#     
#     and an empty string in the list is a landmine — sortuk([""]) reads
#     past the end of the array and calls .lc on it, which dies on both
#     engines. Filter empties out first:
#       filtered : абв банан
