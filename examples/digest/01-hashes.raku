#!/usr/bin/env rakupp
# Digest — One sub per algorithm
# https://raku.online/modules/digest/#one-sub-per-algorithm
#
# Install what it needs, then run it:
#     rakupp install Digest
#     rakupp 01-hashes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::MD5;
use Digest::SHA2;
use Digest::SHA3;
use HMAC;

sub hex(Blob $b) { $b.list.fmt('%02x', '') }

say hex(md5('abc'));
say hex(sha256('abc'));
say hex(sha3_256('abc'));
say sha512('abc').elems;
say hex(hmac(key => 'key', msg => 'The quick brown fox jumps over the lazy dog',
             hash => &sha256, block-size => 64));

# Output:
#     900150983cd24fb0d6963f7d28e17f72
#     ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
#     3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532
#     64
#     f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8
