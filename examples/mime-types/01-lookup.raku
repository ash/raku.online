#!/usr/bin/env rakupp
# MIME::Types — Both directions
# https://raku.online/modules/mime-types/#both-directions
#
# Install what it needs, then run it:
#     rakupp install MIME::Types
#     rakupp 01-lookup.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MIME::Types;

my $m = MIME::Types.new;
say $m.type('html'), ' ', $m.type('png'), ' ', $m.type('json');
say $m.type('nope').raku;
say $m.extensions('text/html').sort.join(',');
say $m.types.elems > 500, ' ', $m.exts.elems > 500;

# Output:
#     text/html image/png application/json
#     Nil
#     htm,html,shtml
#     True True
