#!/usr/bin/env rakupp
# String::Fold — Folding a paragraph
# https://raku.online/modules/string-fold/#folding-a-paragraph
#
# Install what it needs, then run it:
#     rakupp install String::Fold
#     rakupp 01-fold.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use String::Fold;

my $text = 'the quick brown fox jumps over the lazy dog';

for 10, 20, 43 -> $w {
    say "--- width $w";
    say fold($text, :width($w));
}
say '--- default width is 79';
say fold($text).lines.elems, ' line(s)';

# Output:
#     --- width 10
#     the quick
#     brown fox
#     jumps over
#     the lazy
#     dog
#     --- width 20
#     the quick brown fox
#     jumps over the lazy
#     dog
#     --- width 43
#     the quick brown fox jumps over the lazy dog
#     --- default width is 79
#     1 line(s)
