#!/usr/bin/env rakupp
# MIME::Base64 — Text, and what "text" means
# https://raku.online/ecosystem/mime-base64/#text-and-what-text-means
#
# Install what it needs, then run it:
#     rakupp install MIME::Base64
#     rakupp 03-unicode.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use MIME::Base64;

my $text = "naïve café — 日本語";
my $b64  = MIME::Base64.encode-str($text, :oneline);
say $b64;
say MIME::Base64.decode-str($b64);
say MIME::Base64.decode-str($b64) eq $text;

# Output:
#     bmHDr3ZlIGNhZsOpIOKAlCDml6XmnKzoqp4=
#     naïve café — 日本語
#     True
