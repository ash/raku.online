#!/usr/bin/env rakupp
# Text::Caesar — Encrypting and decrypting
# https://raku.online/modules/text-caesar/#encrypting-and-decrypting
#
# Install what it needs, then run it:
#     rakupp install Text::Caesar
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Caesar;

say 'encrypt(3, "attack at dawn") = ', encrypt(3, 'attack at dawn');
say 'decrypt(3, that)            = ', decrypt(3, encrypt(3, 'attack at dawn'));
say '';
say 'rot13 is its own inverse:';
say '  ', encrypt(13, encrypt(13, 'HELLO'));
say '';
say 'only A..Z move; everything else passes straight through:';
say '  encrypt(5, "a-b,c 9") = ', encrypt(5, 'a-b,c 9');

# Output:
#     encrypt(3, "attack at dawn") = DWWDFN DW GDZQ
#     decrypt(3, that)            = ATTACK AT DAWN
#     
#     rot13 is its own inverse:
#       HELLO
#     
#     only A..Z move; everything else passes straight through:
#       encrypt(5, "a-b,c 9") = F-G,H 9
