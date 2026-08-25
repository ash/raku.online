#!/usr/bin/env rakupp
# URI — Absolute, relative, and one method to avoid
# https://raku.online/modules/uri/#absolute-relative-and-one-method-to-avoid
#
# Install what it needs, then run it:
#     rakupp install URI
#     rakupp 09-absolute.raku
#
# Run under Raku++ 3.7.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use URI;

say URI.new('https://example.com/a').is-absolute;
say URI.new('/just/a/path').is-absolute;
say URI.new('/just/a/path').is-relative;

# Output:
#     True
#     False
#     True
