---
name: Lingua::Conjunction
version: 1.3
auth: zef:raku-community-modules
kind: Distribution · text
summary: Turn a list into a natural-language phrase — a, b, and c — with
  control over the conjunction, the Oxford comma, the separator and the
  language.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Lingua::Conjunction
source: https://github.com/raku-community-modules/Lingua-Conjunction.git
---

## What it is for

`@items.join(', ')` gives you `apples, oranges, pears`, which is not what a
person writes. What a person writes is `apples, oranges, and pears` — with no
comma at all when there are two items, and no conjunction when there is one.

Getting that right is four special cases, and every program that reports to a
human needs it.

## Building a phrase

```raku name="conjunction"
use Lingua::Conjunction;

for ('apples',), <apples oranges>, <apples oranges pears>, <a b c d> -> @l {
    say sprintf('%-34s => %s', @l.raku, conjunction(|@l));
}
say '';
say 'type => or  : ', conjunction(<a b c>, :type<or>);
say 'type => and : ', conjunction(<a b c>, :type<and>);
```

```output
("apples",)                        => apples
("apples", "oranges")              => apples and oranges
("apples", "oranges", "pears")     => apples, oranges, and pears
("a", "b", "c", "d")               => a, b, c, and d

type => or  : a, b, or c
type => and : a, b, and c
```

One item comes back unchanged, two get a bare conjunction with no comma, three
or more get the Oxford comma. That is the English convention, and it is four
branches you no longer have to write.

## The switches

```raku name="switches"
use Lingua::Conjunction;

say 'default          : ', conjunction(<a b c>);
say ':last (Oxford)   : ', conjunction(<a b c>, :last);
say ':!last (no comma): ', conjunction(<a b c>, :!last);
say '';
say 'a template       : ', conjunction(<a b c>, :str('I want |list| today'));
say '';
say 'empty list       : ', conjunction().raku;
say 'one item         : ', conjunction('solo').raku;
```

```output
default          : a, b, and c
:last (Oxford)   : a, b, and c
:!last (no comma): a, b and c

a template       : I want a, b, and c today

empty list       : ""
one item         : "solo"
```

`:last` controls the serial comma. The `:str` template drops the phrase into a
sentence, which saves an interpolation.

The empty list returns `""` and a single item returns itself — neither is an
error, which is worth knowing if you expect the conjunction word to always be
there.

## Other languages

```raku name="langs"
use Lingua::Conjunction;

for <en fr es de> -> $lang {
    say sprintf('%-4s => %s', $lang, conjunction(<a b c>, :$lang));
}
```

```output
en   => a, b, and c
fr   => a, b et c
es   => a, b, y c
de   => a, b, und c
```

French drops the serial comma, Spanish and German keep it. The language table
is small; `ja` is present and produces a doubled space where the conjunction
should be, so treat anything beyond these four as untested.

## The one thing to know

An item that already contains the separator silently changes the separator for
the whole list.

```raku name="separator-trap"
use Lingua::Conjunction;

say 'ordinary items  : ', conjunction(<toast jam tea>);
say 'one item has a comma in it:';
say '  ', conjunction('eggs, bacon', 'toast', 'jam');
say '';
say 'the alternate separator is ; by default, and :alt changes it:';
say '  ', conjunction('eggs, bacon', 'toast', 'jam', :alt(' / '));
```

```output
ordinary items  : toast, jam, and tea
one item has a comma in it:
  eggs, bacon; toast; and jam

the alternate separator is ; by default, and :alt changes it:
  eggs, bacon /  toast /  and jam
```

Linguistically this is the right call — a comma-separated list of items that
themselves contain commas is unreadable — and it is clearly deliberate. What
it means in practice is that the **shape** of the output depends on the
**content** of the data: the same call site produces `a, b, and c` for one
dataset and `a; b; and c` for another.

Anything that parses, splits or tests the result against a fixed separator
works until a user types a comma.

## Where the two engines differ

Only on stderr, and only for some inputs: Rakudo emits `Use of Nil in string
context` from line 38 of the module where Raku++ is silent. Every phrase in
this page was byte-identical.

The switch worth knowing about and not using: `:lang<ja>` emits an **empty
conjunction word**, so `conjunction(<a b c>, :lang<ja>)` comes back as
`a, b  c` with a doubled space. The four European languages above are the ones
that work.
