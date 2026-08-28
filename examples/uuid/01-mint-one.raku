#!/usr/bin/env rakupp
# UUID — What it is for
# https://raku.online/modules/uuid/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install UUID
#     rakupp 01-mint-one.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UUID;

my $id = UUID.new;
say "report-{$id}.json";

# One run printed:
#     report-6decb98e-62d2-4532-abff-e5f3139f4ade.json
