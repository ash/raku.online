#!/usr/bin/env rakupp
# OO::Monitors — A monitor is a class that serialises itself
# https://raku.online/modules/oo-monitors/#a-monitor-is-a-class-that-serialises-itself
#
# Install what it needs, then run it:
#     rakupp install OO::Monitors
#     rakupp 01-declare.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use OO::Monitors;

monitor Counter {
    has $!n = 0;
    method inc { $!n++ }
    method n   { $!n }
}

my $counter = Counter.new;
await do for ^4 { start { $counter.inc for ^1000 } }
say $counter.n;
say Counter.^name, ' ', $counter ~~ Counter;

# Output:
#     4000
#     Counter True
