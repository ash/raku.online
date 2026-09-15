#!/usr/bin/env rakupp
# Math::DistanceFunctions::Edit — Two subs
# https://raku.online/modules/math-distancefunctions-edit/#two-subs
#
# Install what it needs, then run it:
#     rakupp install Math::DistanceFunctions::Edit
#     rakupp 02-graphemes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::DistanceFunctions::Edit;

my $composed   = "caf\x[00E9]";
my $decomposed = "cafe\x[0301]";
say $composed.chars, ' ', $decomposed.chars;
say edit-distance($composed, $decomposed);
say edit-distance('café', 'cafe');
say edit-distance('日本', '日本語');

# Output:
#     4 4
#     0
#     1
#     1
