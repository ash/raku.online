#!/usr/bin/env rakupp
# Text::Utils — The chores
# https://raku.online/modules/text-utils/#the-chores
#
# Install what it needs, then run it:
#     rakupp install Text::Utils
#     rakupp 02-wrap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Utils :wrap-paragraph;

my $t = 'The quick brown fox jumps over the lazy dog and keeps running far away from the farm';
.say for wrap-paragraph($t, :max-line-length(32));

# Output:
#     The quick brown fox jumps over
#     the lazy dog and keeps running
#     far away from the farm
