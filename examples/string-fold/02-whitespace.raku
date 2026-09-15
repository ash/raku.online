#!/usr/bin/env rakupp
# String::Fold — What it does to whitespace you already had
# https://raku.online/modules/string-fold/#what-it-does-to-whitespace-you-already-had
#
# Install what it needs, then run it:
#     rakupp install String::Fold
#     rakupp 02-whitespace.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use String::Fold;

sub show($label, $in, $w) {
    say sprintf('%-18s -> %s', $label, fold($in, :width($w)).subst("\n", '|', :g).raku);
}

show 'multiple spaces', 'a     b',           10;
show 'a tab',           "a\tb",              10;
show 'leading space',   '  hi there',        10;
show 'embedded newline', "alpha\nbeta gamma", 8;
show 'empty string',    '',                  10;
show 'spaces only',     '     ',             10;

# Output:
#     multiple spaces    -> "a b"
#     a tab              -> "a b"
#     leading space      -> "hi there"
#     embedded newline   -> "alpha|beta|gamma"
#     empty string       -> ""
#     spaces only        -> ""
