#!/usr/bin/env rakupp
# Text::Spintax — Parsing once, rendering many
# https://raku.online/modules/text-spintax/#parsing-once-rendering-many
#
# Install what it needs, then run it:
#     rakupp install Text::Spintax
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Spintax;

my $tree = Text::Spintax.parse('This {is|was|will be} some {varied|random} text');
say 'the parse result : ', $tree.^name;
say '';
my @seen = (^200).map({ $tree.render }).unique.sort;
say 'distinct renders over 200 calls : ', @seen.elems;
for @seen -> $s { say '  ', $s }
say '';
say 'that is exactly the cross-product, 3 x 2 — so .render re-randomises';
say 'per call and one parse feeds unlimited output.';

# Output:
#     the parse result : Text::Spintax::SequenceNode
#     
#     distinct renders over 200 calls : 6
#       This is some random text
#       This is some varied text
#       This was some random text
#       This was some varied text
#       This will be some random text
#       This will be some varied text
#     
#     that is exactly the cross-product, 3 x 2 — so .render re-randomises
#     per call and one parse feeds unlimited output.
