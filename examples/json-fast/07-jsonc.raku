#!/usr/bin/env rakupp
# JSON::Fast — JSON with comments
# https://raku.online/ecosystem/json-fast/#json-with-comments
#
# Install what it needs, then run it:
#     rakupp install JSON::Fast
#     rakupp 07-jsonc.raku
#
# Run under Raku++ 3.6.0 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Fast;

my $text = q:to/JSONC/;
    {
        // the name of the thing
        "name": "raku",
        /* and how many stars it has */
        "stars": 3
    }
    JSONC

say from-json($text, :allow-jsonc)<name stars>.join(' ');

# Output:
#     raku 3
