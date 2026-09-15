#!/usr/bin/env rakupp
# Text::Chart — The one thing to know
# https://raku.online/modules/text-chart/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::Chart
#     rakupp 04-width.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Chart;

for '#', "\c[CHRISTMAS TREE]" -> $c {
    my $chart = vertical(max => 2, :chart-chars($c), 1, 2, 2);
    say $c eq '#' ?? '=== ASCII: cells line up ===' !! '=== emoji: same .chars, ragged ===';
    for $chart.lines -> $row {
        my $cols = [+] $row.comb.map({ .uniprop('East_Asian_Width') eq 'W'|'F' ?? 2 !! 1 });
        say sprintf('|%s|  .chars=%d  terminal-columns=%d', $row, $row.chars, $cols);
    }
    say '';
}

# Output:
#     === ASCII: cells line up ===
#     | ##|  .chars=3  terminal-columns=3
#     |###|  .chars=3  terminal-columns=3
#     
#     === emoji: same .chars, ragged ===
#     | 🎄🎄|  .chars=3  terminal-columns=5
#     |🎄🎄🎄|  .chars=3  terminal-columns=6
