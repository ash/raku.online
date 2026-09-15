#!/usr/bin/env rakupp
# Text::UpsideDown — The one thing to know
# https://raku.online/modules/text-upsidedown/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::UpsideDown
#     rakupp 02-involution.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::UpsideDown;

my @fail = (0x20 .. 0x7E).map(*.chr).grep({ upside_down(upside_down($_)) ne $_ });
say 'printable ASCII characters that do NOT round-trip : ', @fail.elems;
say '';
say 'so the transform is reversible:';
my $s = 'Hello, World!';
say '  ', $s.raku;
say '  ', upside_down($s).raku;
say '  ', upside_down(upside_down($s)).raku;
say '';
say 'the corollary is that some ASCII letters map to OTHER ASCII letters:';
say '  M and W are each other`s flip, so upside_down("MW") = ',
    upside_down('MW').raku;
say '';
my @fixed = (0x20 .. 0x7E).map(*.chr).grep({ upside_down($_) eq $_ });
say 'characters that are their own flip : ', @fixed.join;

# Output:
#     printable ASCII characters that do NOT round-trip : 0
#     
#     so the transform is reversible:
#       "Hello, World!"
#       "¡pʃɹoM 'oʃʃǝH"
#       "Hello, World!"
#     
#     the corollary is that some ASCII letters map to OTHER ASCII letters:
#       M and W are each other`s flip, so upside_down("MW") = "MW"
#     
#     characters that are their own flip :  #$%+-/02458:=@HIOSXZ\`osxz|~
