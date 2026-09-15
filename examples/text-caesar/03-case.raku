#!/usr/bin/env rakupp
# Text::Caesar — The case trap
# https://raku.online/modules/text-caesar/#the-case-trap
#
# Install what it needs, then run it:
#     rakupp install Text::Caesar
#     rakupp 03-case.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Caesar;

my $cipher = encrypt(3, 'attack at dawn');
say 'ciphertext        : ', $cipher;
say 'decrypt(UPPER)    : ', decrypt(3, $cipher);
say 'decrypt(lowercase): ', decrypt(3, $cipher.lc);
say '';
say 'no error, no warning — the lowercase call is a no-op.';

# Output:
#     ciphertext        : DWWDFN DW GDZQ
#     decrypt(UPPER)    : ATTACK AT DAWN
#     decrypt(lowercase): dwwdfn dw gdzq
#     
#     no error, no warning — the lowercase call is a no-op.
