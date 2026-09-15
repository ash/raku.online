#!/usr/bin/env rakupp
# Text::Chart — What comes back
# https://raku.online/modules/text-chart/#what-comes-back
#
# Install what it needs, then run it:
#     rakupp install Text::Chart
#     rakupp 03-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Chart;

sub describe($label, $v) {
    say sprintf('%-22s %-8s %s', $label, $v.WHAT.^name,
                $v.defined ?? $v.raku !! '(undefined)');
}

describe('max => 2, 1, 2',   vertical(max => 2, 1, 2));
describe('max => 2, no data', vertical(max => 2));
describe('max => 0, 1, 2',   vertical(max => 0, 1, 2));

# Output:
#     max => 2, 1, 2         Str      " █\n██\n"
#     max => 2, no data      Str      "\n\n"
#     max => 0, 1, 2         Any      (undefined)
