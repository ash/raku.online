#!/usr/bin/env rakupp
# Lingua::EN::Stopwords — The one thing to know
# https://raku.online/modules/lingua-en-stopwords/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Stopwords
#     rakupp 03-mutable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Stopwords::Short;

say 'before : is-stop-word("frobnicate") = ', is-stop-word('frobnicate');
%stop-words<frobnicate> = 1;
say 'after  : is-stop-word("frobnicate") = ', is-stop-word('frobnicate');
%stop-words<frobnicate>:delete;
say 'removed: is-stop-word("frobnicate") = ', is-stop-word('frobnicate');
say '';
say 'it is exported as a mutable `our` variable, not a copy. Convenient';
say 'if you want to extend a list; a trap if two parts of one program';
say 'both "customise" it. Take a copy: my %mine = %stop-words;';

# Output:
#     before : is-stop-word("frobnicate") = False
#     after  : is-stop-word("frobnicate") = True
#     removed: is-stop-word("frobnicate") = False
#     
#     it is exported as a mutable `our` variable, not a copy. Convenient
#     if you want to extend a list; a trap if two parts of one program
#     both "customise" it. Take a copy: my %mine = %stop-words;
