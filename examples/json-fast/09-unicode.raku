#!/usr/bin/env rakupp
# JSON::Fast — Unicode, and the pair of escapes above U+FFFF
# https://raku.online/ecosystem/json-fast/#unicode-and-the-pair-of-escapes-above-uffff
#
# Install what it needs, then run it:
#     rakupp install JSON::Fast
#     rakupp 09-unicode.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Fast;

my $json = to-json({ text => "möp stüff — 𝄞" }, :!pretty);
say $json;
say from-json($json)<text>;
say from-json($json)<text> eq "möp stüff — 𝄞";

# Output:
#     {"text":"möp stüff — \uD834\uDD1E"}
#     möp stüff — 𝄞
#     True
