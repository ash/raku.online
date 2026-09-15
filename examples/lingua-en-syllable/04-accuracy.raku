#!/usr/bin/env rakupp
# Lingua::EN::Syllable — Where the two engines differ
# https://raku.online/modules/lingua-en-syllable/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Syllable
#     rakupp 04-accuracy.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Syllable;

for 'queue'   => 1,
    'rhythm'  => 2,
    'onomatopoeia' => 6,
    'cat'     => 1,
    'table'   => 2 -> $p {
    my $got = syllable($p.key);
    say sprintf('%-14s counted %d, actually %d  %s',
        $p.key, $got, $p.value, $got == $p.value ?? 'ok' !! 'off');
}

# Output:
#     queue          counted 2, actually 1  off
#     rhythm         counted 1, actually 2  off
#     onomatopoeia   counted 7, actually 6  off
#     cat            counted 1, actually 1  ok
#     table          counted 2, actually 2  ok
