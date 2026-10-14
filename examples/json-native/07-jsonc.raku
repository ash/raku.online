#!/usr/bin/env rakupp
# JSON::Native — Comments, and refusals in JSON::Fast's words
# https://raku.online/modules/json-native/#comments-and-refusals-in-jsonfasts-words
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 07-jsonc.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Native;

my $text = q:to/JSONC/;
    {
        // not JSON, until you allow it
        "a": 1
    }
    JSONC
say from-json($text, :allow-jsonc)<a>;

# Output:
#     1
