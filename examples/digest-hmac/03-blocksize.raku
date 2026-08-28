#!/usr/bin/env rakupp
# Digest::HMAC — Raw bytes, and the blocksize trap
# https://raku.online/modules/digest-hmac/#raw-bytes-and-the-blocksize-trap
#
# Install what it needs, then run it:
#     rakupp install Digest::HMAC
#     rakupp 03-blocksize.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::HMAC;
use Digest::SHA2;

my $tag = hmac('key', 'message', &sha256);
say $tag ~~ Blob;
say $tag.elems;

say hmac-hex('key', 'message', &sha512, 128).substr(0, 16);

# Output:
#     True
#     32
#     e477384d7ca229dd
