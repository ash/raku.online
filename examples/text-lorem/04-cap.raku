#!/usr/bin/env rakupp
# Text::Lorem — The one thing to know
# https://raku.online/modules/text-lorem/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::Lorem
#     rakupp 04-cap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Lorem;

my $l = Text::Lorem.new;
say 'vocabulary slots : ', $l.lorem-words.elems;
say 'distinct values  : ', $l.lorem-words.unique.elems;
say '';
for 5, 50, 184, 200, 1000 -> $n {
    say sprintf('words(%4d) -> %d words', $n, $l.words($n).words.elems);
}
say '';
say 'a 500-word placeholder block — the obvious use for a lorem-ipsum';
say 'module — gets you 184 words and a full stop, and a length assertion';
say 'in a test fails with no clue why.';

# Output:
#     vocabulary slots : 184
#     distinct values  : 146
#     
#     words(   5) -> 5 words
#     words(  50) -> 50 words
#     words( 184) -> 184 words
#     words( 200) -> 184 words
#     words(1000) -> 184 words
#     
#     a 500-word placeholder block — the obvious use for a lorem-ipsum
#     module — gets you 184 words and a full stop, and a length assertion
#     in a test fails with no clue why.
