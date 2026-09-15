#!/usr/bin/env rakupp
# Lingua::Conjunction — Building a phrase
# https://raku.online/modules/lingua-conjunction/#building-a-phrase
#
# Install what it needs, then run it:
#     rakupp install Lingua::Conjunction
#     rakupp 01-conjunction.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Conjunction;

for ('apples',), <apples oranges>, <apples oranges pears>, <a b c d> -> @l {
    say sprintf('%-34s => %s', @l.raku, conjunction(|@l));
}
say '';
say 'type => or  : ', conjunction(<a b c>, :type<or>);
say 'type => and : ', conjunction(<a b c>, :type<and>);

# Output:
#     ("apples",)                        => apples
#     ("apples", "oranges")              => apples and oranges
#     ("apples", "oranges", "pears")     => apples, oranges, and pears
#     ("a", "b", "c", "d")               => a, b, c, and d
#     
#     type => or  : a, b, or c
#     type => and : a, b, and c
