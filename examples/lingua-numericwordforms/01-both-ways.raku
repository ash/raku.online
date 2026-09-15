#!/usr/bin/env rakupp
# Lingua::NumericWordForms — Reading and writing
# https://raku.online/modules/lingua-numericwordforms/#reading-and-writing
#
# Install what it needs, then run it:
#     rakupp install Lingua::NumericWordForms
#     rakupp 01-both-ways.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::NumericWordForms;

for 0, 42, 1234, 2026, 1_000_000 -> $n {
    my $words = to-numeric-word-form($n);
    say $n, ' -> ', $words, ' -> ', from-numeric-word-form($words);
}

say to-numeric-word-form([1, 2, 3], 'English');
say from-numeric-word-form(['one', 'two', 'three']);

# Output:
#     0 -> zero -> 0
#     42 -> forty two -> 42
#     1234 -> one thousand, two hundred thirty four -> 1234
#     2026 -> two thousand, twenty six -> 2026
#     1000000 -> one million -> 1000000
#     (one two three)
#     (1 2 3)
