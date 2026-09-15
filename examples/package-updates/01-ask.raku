#!/usr/bin/env rakupp
# Package::Updates — Asking
# https://raku.online/modules/package-updates/#asking
#
# Install what it needs, then run it:
#     rakupp install Package::Updates
#     rakupp 01-ask.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Package::Updates;

my $t0 = now;
my %updates = get-updates();
my $elapsed = now - $t0;

say 'returns a : ', %updates.^name;
say 'entries   : ', %updates.elems;
say 'Bool      : ', ?%updates;
say 'and it answered in under a second : ', $elapsed < 1;

# Output:
#     returns a : Hash
#     entries   : 0
#     Bool      : False
#     and it answered in under a second : True
