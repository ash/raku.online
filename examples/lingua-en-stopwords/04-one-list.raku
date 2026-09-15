#!/usr/bin/env rakupp
# Lingua::EN::Stopwords — Where the two engines differ
# https://raku.online/modules/lingua-en-stopwords/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Lingua::EN::Stopwords
#     rakupp 04-one-list.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::EN::Stopwords::Short;

# to compare two lists, load one and read the other through its package
my %short = %stop-words;
say 'Short loaded here : ', %short.elems;
say '';
say 'loading a SECOND variant into the same scope is a compile error on';
say 'Rakudo — "Cannot import the following symbols … because they already';
say 'exist in this lexical scope". Raku++ merges the two `our` hashes into';
say 'one instead, so the union silently becomes the list you are using.';
say '';
say 'If you need two, load them in separate scopes or separate files.';

# Output:
#     Short loaded here : 174
#     
#     loading a SECOND variant into the same scope is a compile error on
#     Rakudo — "Cannot import the following symbols … because they already
#     exist in this lexical scope". Raku++ merges the two `our` hashes into
#     one instead, so the union silently becomes the list you are using.
#     
#     If you need two, load them in separate scopes or separate files.
