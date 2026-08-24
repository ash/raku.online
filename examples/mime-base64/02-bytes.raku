#!/usr/bin/env rakupp
# MIME::Base64 — Bytes
# https://raku.online/ecosystem/mime-base64/#bytes
#
# Install what it needs, then run it:
#     rakupp install MIME::Base64
#     rakupp 02-bytes.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MIME::Base64;

my $blob = Buf.new(0x00, 0xff, 0x10, 0x80, 0x7f);
my $b64  = MIME::Base64.encode($blob);
say $b64;
say MIME::Base64.decode($b64).list.fmt('%02x', ' ');
say MIME::Base64.decode($b64) eqv $blob;

# Output:
#     AP8QgH8=
#     00 ff 10 80 7f
#     True
