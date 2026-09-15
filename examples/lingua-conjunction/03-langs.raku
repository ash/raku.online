#!/usr/bin/env rakupp
# Lingua::Conjunction — Other languages
# https://raku.online/modules/lingua-conjunction/#other-languages
#
# Install what it needs, then run it:
#     rakupp install Lingua::Conjunction
#     rakupp 03-langs.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Conjunction;

for <en fr es de> -> $lang {
    say sprintf('%-4s => %s', $lang, conjunction(<a b c>, :$lang));
}

# Output:
#     en   => a, b, and c
#     fr   => a, b et c
#     es   => a, b, y c
#     de   => a, b, und c
