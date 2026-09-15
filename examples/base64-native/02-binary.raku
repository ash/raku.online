#!/usr/bin/env rakupp
# Base64::Native — Binary
# https://raku.online/modules/base64-native/#binary
#
# Install what it needs, then run it:
#     rakupp install Base64::Native
#     rakupp 02-binary.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Base64::Native;

my $blob = Blob.new(0, 1, 2, 250, 251, 255);
my $enc  = base64-encode($blob, :str);
say 'bytes   : ', $blob.list.join(' ');
say 'encoded : ', $enc.raku;
say 'decoded : ', base64-decode($enc).list.join(' ');
say 'exact   : ', base64-decode($enc).list eqv $blob.list;

# Output:
#     bytes   : 0 1 2 250 251 255
#     encoded : "AAEC+vv/"
#     decoded : 0 1 2 250 251 255
#     exact   : True
