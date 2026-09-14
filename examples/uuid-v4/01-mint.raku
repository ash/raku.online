#!/usr/bin/env rakupp
# UUID::V4 — Both subs
# https://raku.online/modules/uuid-v4/#both-subs
#
# Install what it needs, then run it:
#     rakupp install UUID::V4
#     rakupp 01-mint.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UUID::V4;

my $id = uuid-v4();

say $id.chars;
say $id.substr(14, 1);
say $id.comb('-').elems;

say is-uuid-v4($id);
say is-uuid-v4('3f4a-not-a-uuid');

# Output:
#     36
#     4
#     4
#     True
#     False
