#!/usr/bin/env rakupp
# Text::Spintax — Parsing once, rendering many
# https://raku.online/modules/text-spintax/#parsing-once-rendering-many
#
# Install what it needs, then run it:
#     rakupp install Text::Spintax
#     rakupp 02-nesting.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Spintax;

my $tree = Text::Spintax.parse('{a{1|2}|b}');
say 'distinct : ', (^200).map({ $tree.render }).unique.sort.join(' ');
say '';
say 'an empty alternative is legal, and one of its outcomes is "":';
my $empty = Text::Spintax.parse('{a||b}');
say '  ', (^200).map({ $empty.render.raku }).unique.sort.join(' ');
say '';
say 'and so is an empty group:';
say '  {} renders as ', Text::Spintax.parse('{}').render.raku;

# Output:
#     distinct : a1 a2 b
#     
#     an empty alternative is legal, and one of its outcomes is "":
#       "" "a" "b"
#     
#     and so is an empty group:
#       {} renders as ""
