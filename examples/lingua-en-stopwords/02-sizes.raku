#!/usr/bin/env rakupp
# Lingua::EN::Stopwords — The three lists
# https://raku.online/modules/lingua-en-stopwords/#the-three-lists
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Stopwords
#     rakupp 02-sizes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Stopwords::Long;

say 'Long list : ', %stop-words.elems, ' entries';
say '';
say 'it is not a general English list — it is a biomedical-abstract one:';
for <able value important significant research zero nine> -> $w {
    say sprintf('  %-12s -> %s', $w, is-stop-word($w));
}
say '';
my $letters = ('a' .. 'z').grep({ is-stop-word($_) }).join;
say 'single letters on the list : ', $letters;
say '';
say 'run general prose through Long and you delete the content words.';

# Output:
#     Long list : 667 entries
#     
#     it is not a general English list — it is a biomedical-abstract one:
#       able         -> True
#       value        -> True
#       important    -> True
#       significant  -> True
#       research     -> True
#       zero         -> True
#       nine         -> True
#     
#     single letters on the list : abcdefghijklmnopqrstuvwxyz
#     
#     run general prose through Long and you delete the content words.
