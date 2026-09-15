#!/usr/bin/env rakupp
# Lingua::EN::Syllable — Counting syllables
# https://raku.online/modules/lingua-en-syllable/#counting-syllables
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Syllable
#     rakupp 01-syllable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Syllable;

for <cat table syllable beautiful university Mississippi
     strength onomatopoeia> -> $w {
    say sprintf('%-16s => %d', $w, syllable($w));
}

# Output:
#     cat              => 1
#     table            => 2
#     syllable         => 3
#     beautiful        => 4
#     university       => 5
#     Mississippi      => 4
#     strength         => 1
#     onomatopoeia     => 7
