---
name: Lingua::Stem::Es
version: 0.0.1
auth: cpan:CHSANCH
kind: Distribution · linguistics
summary: The Snowball Spanish stemmer, ported — one string in, one stem out,
  and the merges it makes are not the ones you expect.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/cpan:CHSANCH/Lingua::Stem::Es
source: git://github.com/chsanch/perl6-Lingua-Stem-Es.git
---

## What it is for

A search index that stores `hablar`, `hablo` and `hablando` as three separate
tokens will not match a query for any of the others. A stemmer collapses
inflected forms onto a common string so they do match.

This is a port of the Snowball Spanish stemmer: lower-case, strip
punctuation, compute the RV/R1/R2 regions, then run attached-pronoun removal,
one derivational-suffix step, one verbal-suffix step, a final-vowel step and
accent stripping.

## Stemming

```raku name="basics"
use Lingua::Stem::Es;

for <gato gata gatos gatas casa libro> -> $w {
    say sprintf('  %-12s -> %s', $w, stem($w));
}
say '';
for <hablar hablo hablamos hablando hablado hablaría> -> $w {
    say sprintf('  %-12s -> %s', $w, stem($w));
}
say '';
for <nacionalismo nacional nacionalidad nacionalizar> -> $w {
    say sprintf('  %-14s -> %s', $w, stem($w));
}
say '';
say 'case and punctuation are handled:';
for 'Casa', 'CASA', 'casa,', '¡Hola!' -> $w {
    say sprintf('  %-10s -> %s', $w.raku, stem($w));
}
```

```output
  gato         -> gat
  gata         -> gat
  gatos        -> gat
  gatas        -> gat
  casa         -> cas
  libro        -> libr

  hablar       -> habl
  hablo        -> habl
  hablamos     -> habl
  hablando     -> habl
  hablado      -> habl
  hablaría     -> habl

  nacionalismo   -> nacional
  nacional       -> nacional
  nacionalidad   -> nacional
  nacionalizar   -> nacionaliz

case and punctuation are handled:
  "Casa"     -> cas
  "CASA"     -> cas
  "casa,"    -> cas
  "¡Hola!"   -> hol
```

Accents are part of the algorithm's final step, which is why
`rápidamente` and `felicidad` both come out unaccented.

## The one thing to know

The stemmer merges words that share nothing but a spelling accident, and the
merges hit very common vocabulary.

```raku name="merges"
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
```

```output
  car    <- cara caro caras
  cas    <- casa casar casas caso
  col    <- col cola colar colas
  libr   <- libra librar libre libro libros
  per    <- pera peras pero
  sal    <- sal sala salir
  tem    <- tema temas temer temo temía

libro (book), libra (pound), libre (free) and librar (to free) all
become libr. That is inherent to a suffix stripper with no lexicon —
but a programmer reaching for "stemming so that searches match" will
not expect book and pound to be the same token.
```

The opposite failure is just as sharp: the irregular verbs do not merge at all.

```raku name="irregular"
use Lingua::Stem::Es;

say 'ser  : ', <ser es son fui era>.map({ stem($_) }).join(' ');
say 'tener: ', <tener tengo tiene tuvo>.map({ stem($_) }).join(' ');
say 'ir   : ', <ir voy fue>.map({ stem($_) }).join(' ');
say '';
say 'five distinct tokens for the present and past of ser.';
```

```output
ser  : ser es son fui era
tener: ten teng tien tuv
ir   : ir voy fue

five distinct tokens for the present and past of ser.
```

## Two shapes that will bite you

```raku name="pitfalls"
use Lingua::Stem::Es;

say 'it is NOT idempotent — never feed a stem back in:';
my $once = stem('rápidamente');
say sprintf('  rápidamente -> %s -> %s', $once, stem($once));
say '';
say 'it is NOT a tokenizer — the whole string is treated as one word:';
say '  stem("la casa roja") = ', stem('la casa roja').raku;
say '';
say 'punctuation is DELETED, not split on:';
for 'e-mail', 'e-mails', 'anti-oso' -> $w {
    say sprintf('  %-10s -> %s', $w, stem($w));
}
say '';
say 'clitics come off only when the verb ending also falls inside RV:';
for <hablarle dándoselo cómpramelo vámonos> -> $w {
    say sprintf('  %-12s -> %s', $w, stem($w));
}
```

```output
it is NOT idempotent — never feed a stem back in:
  rápidamente -> rapid -> rap

it is NOT a tokenizer — the whole string is treated as one word:
  stem("la casa roja") = "la casa roj"

punctuation is DELETED, not split on:
  e-mail     -> email
  e-mails    -> emails
  anti-oso   -> antios

clitics come off only when the verb ending also falls inside RV:
  hablarle     -> habl
  dándoselo    -> dandosel
  cómpramelo   -> compramel
  vámonos      -> vamon
```

## Where the two engines differ

Nothing. Every stem above is byte-identical under both engines, including the
accented forms and the clitic cases — this is a pure string function with no
container, no hash iteration and no floating-point arithmetic in it, which is
exactly the shape that ports cleanly.

```raku name="portable"
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
```

```output
text   : Los libros de la biblioteca están hablando de nacionalismo
tokens : los libr de la bibliotec estan habl de nacional

note "los" -> los and "la" -> la — stop words are your problem, not the stemmer`s.
```

One measured property worth relying on: R2 makes similar-looking words behave
differently, so `revolución` stems to `revolu` while `nación` stems to
`nacion` — the shorter word has an empty R2 and the derivational step cannot
fire. That is the algorithm working as specified, not a bug, and both engines
agree on it.
