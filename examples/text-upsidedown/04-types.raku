#!/usr/bin/env rakupp
# Text::UpsideDown — Where the two engines differ
# https://raku.online/modules/text-upsidedown/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Text::UpsideDown
#     rakupp 04-types.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::UpsideDown;

say 'the parameter is Str with no Cool coercion, so coerce yourself:';
my $n = 42;
say '  upside_down($n.Str) = ', upside_down($n.Str).raku;
say '';
say 'there is one Unicode subtlety worth knowing before you scan a wide';
say 'range of codepoints through this function. Raku++ does not NFC-';
say 'normalise Int.chr, so a compatibility character such as the Kelvin';
say 'sign stays distinct from the letter K there and folds to it on';
say 'Rakudo — which makes a "does every codepoint round-trip?" sweep';
say 'disagree between the engines for about 565 codepoints.';
say '';
say 'printable ASCII is unaffected, which is what the table covers:';
my @fail = (0x20 .. 0x7E).map(*.chr).grep({ upside_down(upside_down($_)) ne $_ });
say '  ASCII failures : ', @fail.elems;

# Output:
#     the parameter is Str with no Cool coercion, so coerce yourself:
#       upside_down($n.Str) = "24"
#     
#     there is one Unicode subtlety worth knowing before you scan a wide
#     range of codepoints through this function. Raku++ does not NFC-
#     normalise Int.chr, so a compatibility character such as the Kelvin
#     sign stays distinct from the letter K there and folds to it on
#     Rakudo — which makes a "does every codepoint round-trip?" sweep
#     disagree between the engines for about 565 codepoints.
#     
#     printable ASCII is unaffected, which is what the table covers:
#       ASCII failures : 0
