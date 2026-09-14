#!/usr/bin/env rakupp
# Crypt::Random — Draws
# https://raku.online/modules/crypt-random/#draws
#
# Install what it needs, then run it:
#     rakupp install Crypt::Random
#     rakupp 01-draws.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Crypt::Random;
use Crypt::Random::Extra;

say crypt_random_buf(8);
say crypt_random(2);
say crypt_random_uniform(6);
say crypt_random_UUIDv4;
say crypt_random_sample(['a'..'f'], 3);

# One run printed:
#     Buf:0x<7A 03 D1 5E 9C 2B 44 F0>
#     41207
#     3
#     9f1c2e8a-6b4d-4c3e-8a5f-0d2b7e4c9a11
#     [e b e]
