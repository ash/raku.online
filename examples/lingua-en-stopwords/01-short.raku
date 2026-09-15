#!/usr/bin/env rakupp
# Lingua::EN::Stopwords — The three lists
# https://raku.online/modules/lingua-en-stopwords/#the-three-lists
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Stopwords
#     rakupp 01-short.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Stopwords::Short;

say 'Short list   : ', %stop-words.elems, ' entries';
for 'the', 'THE', 'The', "aren't", 'frobnicate', '' -> $w {
    say sprintf('  is-stop-word(%-12s) = %s', $w.raku, is-stop-word($w));
}
say '';
say 'the lookup lower-cases, so case does not matter — but punctuation';
say 'does: is-stop-word("the.") = ', is-stop-word('the.');

# Output:
#     Short list   : 174 entries
#       is-stop-word("the"       ) = True
#       is-stop-word("THE"       ) = True
#       is-stop-word("The"       ) = True
#       is-stop-word("aren't"    ) = True
#       is-stop-word("frobnicate") = False
#       is-stop-word(""          ) = False
#     
#     the lookup lower-cases, so case does not matter — but punctuation
#     does: is-stop-word("the.") = False
