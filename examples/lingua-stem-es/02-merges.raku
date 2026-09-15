#!/usr/bin/env rakupp
# Lingua::Stem::Es — The one thing to know
# https://raku.online/modules/lingua-stem-es/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::Stem::Es
#     rakupp 02-merges.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::Stem::Es;

my %groups;
for <libra librar libre libro libros tema temas temer temo temía
     col cola colar colas sal sala salir pera peras pero
     cara caro caras casa casar casas caso> -> $w {
    %groups{stem($w)}.push($w);
}
for %groups.keys.sort -> $s {
    next unless %groups{$s}.elems > 1;
    say sprintf('  %-6s <- %s', $s, %groups{$s}.join(' '));
}
say '';
say 'libro (book), libra (pound), libre (free) and librar (to free) all';
say 'become libr. That is inherent to a suffix stripper with no lexicon —';
say 'but a programmer reaching for "stemming so that searches match" will';
say 'not expect book and pound to be the same token.';

# Output:
#       car    <- cara caro caras
#       cas    <- casa casar casas caso
#       col    <- col cola colar colas
#       libr   <- libra librar libre libro libros
#       per    <- pera peras pero
#       sal    <- sal sala salir
#       tem    <- tema temas temer temo temía
#     
#     libro (book), libra (pound), libre (free) and librar (to free) all
#     become libr. That is inherent to a suffix stripper with no lexicon —
#     but a programmer reaching for "stemming so that searches match" will
#     not expect book and pound to be the same token.
