#!/usr/bin/env rakupp
# URI — The path, and its segments
# https://raku.online/modules/uri/#the-path-and-its-segments
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 05-segments.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI;

say URI.new('https://example.com/a/b/').segments.raku;
say URI.new('https://example.com/a/b').segments.raku;
say URI.new('https://example.com').path.Str.raku;

# Output:
#     ("", "a", "b", "")
#     ("", "a", "b")
#     ""
