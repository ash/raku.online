#!/usr/bin/env rakupp
# JSON::Native — `:immutable` is claimed; everything else is delegated
# https://raku.online/modules/json-native/#immutable-is-claimed-everything-else-is-delegated
#
# Install what it needs, then run it:
#     rakupp install JSON::Native
#     rakupp 06-delegate.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
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
