#!/usr/bin/env rakupp
# Lingua::EN::Syllable — Case and punctuation
# https://raku.online/modules/lingua-en-syllable/#case-and-punctuation
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Syllable
#     rakupp 02-input.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Syllable;

for <banana Banana BANANA> -> $w {
    say sprintf('%-10s => %d', $w, syllable($w));
}
say '';
for "don't", 'hello-world', 'co-operate' -> $w {
    say sprintf('%-14s => %d', $w.raku, syllable($w));
}

# Output:
#     banana     => 3
#     Banana     => 3
#     BANANA     => 3
#     
#     "don't"        => 1
#     "hello-world"  => 3
#     "co-operate"   => 4
