#!/usr/bin/env rakupp
# Digest::SHA1::Native — Both subs
# https://raku.online/modules/digest-sha1-native/#both-subs
#
# Install what it needs, then run it:
#     rakupp install Digest::SHA1::Native
#     rakupp 01-sha1.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::SHA1::Native;

say sha1-hex('hello');
say sha1-hex('');
say sha1('hello').elems;
say sha1-hex('hello'.encode) eq sha1-hex('hello');

my $t0 = now;
sha1-hex('x' x 1_000_000);
say now - $t0 < 1;

# Output:
#     aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
#     da39a3ee5e6b4b0d3255bfef95601890afd80709
#     20
#     True
#     True
