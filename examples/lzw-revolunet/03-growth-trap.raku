#!/usr/bin/env rakupp
# LZW::Revolunet — The one thing to know
# https://raku.online/modules/lzw-revolunet/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install LZW::Revolunet
#     rakupp 03-growth-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use LZW::Revolunet;

my $lzw = LZW::Revolunet.new;

printf("%-34s %6s %7s %8s %9s %8s\n",
       'input', 'chars', 'bytes', 'c.bytes', 'ratio()', 'verdict');
for 'TOBEORNOTTOBEORTOBEORNOT', 'hello hello hello hello',
    'a' x 60, 'abcdefghijklmnopqrstuvwxyz',
    ('the quick brown fox ' x 5) -> $in {
    my $c  = $lzw.compress(s => $in);
    my $ib = $in.encode('utf8').bytes;
    my $cb = $c.encode('utf8').bytes;
    printf("%-34s %6d %7d %8d %9d %8s\n",
        $in.chars > 32 ?? $in.substr(0, 29) ~ '...' !! $in,
        $in.chars, $ib, $cb, $lzw.get_ratio(),
        $cb < $ib ?? 'smaller' !! 'LARGER');
}

# Output:
#     input                               chars   bytes  c.bytes   ratio()  verdict
#     TOBEORNOTTOBEORTOBEORNOT               24      24       37       -25   LARGER
#     hello hello hello hello                23      23       38       -31   LARGER
#     aaaaaaaaaaaaaaaaaaaaaaaaaaaaa...       60      60       41        48  smaller
#     abcdefghijklmnopqrstuvwxyz             26      26       26         0   LARGER
#     the quick brown fox the quick...      100     100      153       -20   LARGER
