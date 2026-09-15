#!/usr/bin/env rakupp
# Lingua::EN::Syllable — The one thing to know
# https://raku.online/modules/lingua-en-syllable/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Syllable
#     rakupp 03-floor-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Syllable;

for '', '   ', '123', '---', '42.7' -> $w {
    say sprintf('%-10s => %d', $w.raku, syllable($w));
}
say '';
say 'there is no return value that means "I could not analyse this"';

# Output:
#     ""         => 1
#     "   "      => 1
#     "123"      => 1
#     "---"      => 1
#     "42.7"     => 1
#     
#     there is no return value that means "I could not analyse this"
