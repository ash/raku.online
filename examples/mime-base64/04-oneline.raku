#!/usr/bin/env rakupp
# MIME::Base64 — `:oneline`, and why the default has newlines in it
# https://raku.online/modules/mime-base64/#oneline-and-why-the-default-has-newlines-in-it
#
# Install what it needs, then run it:
#     rakupp install MIME::Base64
#     rakupp 04-oneline.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MIME::Base64;

my $long = Buf.new(0..99);
say MIME::Base64.encode($long).lines.elems;
say MIME::Base64.encode($long, :oneline).lines.elems;
say MIME::Base64.encode($long).lines[0].chars;

# Output:
#     2
#     1
#     76
