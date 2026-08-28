#!/usr/bin/env rakupp
# Base64 — The URL-safe alphabet
# https://raku.online/modules/base64/#the-url-safe-alphabet
#
# Install what it needs, then run it:
#     rakupp install Base64
#     rakupp 02-url-safe.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Base64;

my $bytes = Blob.new(251, 255, 190);
say encode-base64($bytes, :str);
say encode-base64($bytes, :str, :uri);
say decode-base64('-_--', :uri, :bin).list;

# Output:
#     +/++
#     -_--
#     (251 255 190)
