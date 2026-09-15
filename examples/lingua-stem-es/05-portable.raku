#!/usr/bin/env rakupp
# Lingua::Stem::Es — Where the two engines differ
# https://raku.online/modules/lingua-stem-es/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Lingua::Stem::Es
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Stem::Es;

# what a search index actually wants: tokenize first, then stem each token
sub tokens(Str $text) {
    $text.lc.comb(/ <[\w] + [áéíóúüñ]>+ /).map({ stem($_) })
}

my $text = 'Los libros de la biblioteca están hablando de nacionalismo';
say 'text   : ', $text;
say 'tokens : ', tokens($text).join(' ');
say '';
say 'note "los" -> ', stem('los'), ' and "la" -> ', stem('la'),
    ' — stop words are your problem, not the stemmer`s.';

# Output:
#     text   : Los libros de la biblioteca están hablando de nacionalismo
#     tokens : los libr de la bibliotec estan habl de nacional
#     
#     note "los" -> los and "la" -> la — stop words are your problem, not the stemmer`s.
