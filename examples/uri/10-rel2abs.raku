#!/usr/bin/env rakupp
# URI — Absolute, relative, and one method to avoid
# https://raku.online/ecosystem/uri/#absolute-relative-and-one-method-to-avoid
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 10-rel2abs.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI;

my $base = URI.new('https://example.com/docs/guide/index.html');
say URI.new('/top.html').rel2abs($base);
say URI.new('https://other.example/x').rel2abs($base);

# Output:
#     https://example.com/top.html
#     https://other.example/x
