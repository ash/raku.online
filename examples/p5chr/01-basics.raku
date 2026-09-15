#!/usr/bin/env rakupp
# P5chr — Using it
# https://raku.online/modules/p5chr/#using-it
#
# Install what it needs, then run it:
#     rakupp install P5chr
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5chr;

say 'chr(65)      = ', chr(65).raku;
say 'ord("A")     = ', ord('A');
say 'ord("abc")   = ', ord('abc'), '   <- the first character, not an error';
say 'ord("")      = ', ord('').raku;
say 'chr(0)       = ', chr(0).ords.raku;
say 'chr(-1)      = ', chr(-1).ords.raku, '   <- the replacement character';
say '';
say 'round trip over printable ASCII : ',
    so (0x20 .. 0x7E).all.map({ ord(chr($_)) == $_ });

# Output:
#     chr(65)      = "A"
#     ord("A")     = 65
#     ord("abc")   = 97   <- the first character, not an error
#     ord("")      = Nil
#     chr(0)       = (0,).Seq
#     chr(-1)      = (65533,).Seq   <- the replacement character
#     
#     round trip over printable ASCII : True
