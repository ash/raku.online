#!/usr/bin/env rakupp
# P5hex — Using it
# https://raku.online/modules/p5hex/#using-it
#
# Install what it needs, then run it:
#     rakupp install P5hex
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5hex;

say 'hex("ff")     = ', hex('ff');
say 'hex("FF")     = ', hex('FF');
say 'hex("0xff")   = ', hex('0xff'), '   <- the prefix is accepted';
say 'hex("")       = ', hex('').raku;
say '';
say 'oct("755")    = ', oct('755'), '   <- octal by default';
say 'oct("0755")   = ', oct('0755');
say 'oct("0b101")  = ', oct('0b101'), '     <- binary via the prefix';
say 'oct("0o17")   = ', oct('0o17');

# Output:
#     hex("ff")     = 255
#     hex("FF")     = 255
#     hex("0xff")   = 255   <- the prefix is accepted
#     hex("")       = 0
#     
#     oct("755")    = 493   <- octal by default
#     oct("0755")   = 493
#     oct("0b101")  = 5     <- binary via the prefix
#     oct("0o17")   = 15
