#!/usr/bin/env rakupp
# List::Allmax — The one thing to know
# https://raku.online/modules/list-allmax/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install List::Allmax
#     rakupp 03-by-calls.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use List::Allmax;

my @seen;
my @words = <pear fig plum kiwi>;
my @r = all-max(@words, by => -> $w { @seen.push($w); $w.chars });

say 'result              : ', @r.raku;
say '';
say ':by was applied to  : ', @seen.raku;
say '  ', @words.elems, ' elements, ', @seen.elems, ' applications';
say '';
say 'the comparator is { &by($^a) cmp &by($^b) } and each element is';
say 'compared twice — once for == 0 and once for > 0. "pear", the running';
say 'maximum, is passed to :by five times for a four-element list.';
say '';
say 'so a :by that is not a PURE function of its argument silently';
say 'returns a wrong answer, and one that costs money — a database lookup,';
say 'a hash miss — costs 2.5n rather than n. Memoise it, or precompute:';
my %len = @words.map({ $_ => .chars });
say '  precomputed : ', all-max(@words, by => { %len{$_} }).raku;

# Output:
#     result              : ["pear", "plum", "kiwi"]
#     
#     :by was applied to  : ["pear", "pear", "fig", "pear", "fig", "pear", "plum", "pear", "kiwi", "pear"]
#       4 elements, 10 applications
#     
#     the comparator is { &by($^a) cmp &by($^b) } and each element is
#     compared twice — once for == 0 and once for > 0. "pear", the running
#     maximum, is passed to :by five times for a four-element list.
#     
#     so a :by that is not a PURE function of its argument silently
#     returns a wrong answer, and one that costs money — a database lookup,
#     a hash miss — costs 2.5n rather than n. Memoise it, or precompute:
#       precomputed : ["pear", "plum", "kiwi"]
