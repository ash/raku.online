#!/usr/bin/env rakupp
# Algorithm::Soundex — What it does with the input
# https://raku.online/modules/algorithm-soundex/#what-it-does-with-the-input
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Soundex
#     rakupp 02-input.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::Soundex;

my $sx = Algorithm::Soundex.new;

for 'smith', 'SMITH', 'SmItH', "O'Brien", 'Smith-Jones', 'aeiou', '' -> $in {
    say sprintf('%-14s -> %s', $in.raku, $sx.soundex($in).raku);
}
say '';
say 'the argument is untyped and Cool-coerced:';
say '  soundex(42) -> ', $sx.soundex(42).raku;

# Output:
#     "smith"        -> "S530"
#     "SMITH"        -> "S530"
#     "SmItH"        -> "S530"
#     "O'Brien"      -> "O165"
#     "Smith-Jones"  -> "S532"
#     "aeiou"        -> "A000"
#     ""             -> ""
#     
#     the argument is untyped and Cool-coerced:
#       soundex(42) -> "400"
