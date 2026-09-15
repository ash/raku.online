#!/usr/bin/env rakupp
# Digest::MD5 — One sub
# https://raku.online/modules/digest-md5/#one-sub
#
# Install what it needs, then run it:
#     rakupp install Digest::MD5
#     rakupp 01-md5.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::MD5;

sub hex(Blob $b) { $b.list.map({ .fmt('%02x') }).join }

say hex(md5(''));
say hex(md5('abc'));
say hex(md5('The quick brown fox jumps over the lazy dog'));
say md5('abc').elems;
say hex(md5('abc')) eq hex(md5('abc'.encode));

# Output:
#     d41d8cd98f00b204e9800998ecf8427e
#     900150983cd24fb0d6963f7d28e17f72
#     9e107d9d372bb6826bd81d3542a419d6
#     16
#     True
