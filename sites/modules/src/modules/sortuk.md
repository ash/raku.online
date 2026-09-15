---
name: sortuk
version: 0.0.2
auth: zef:andmizyk
kind: Distribution · localisation
summary: Ukrainian-alphabet sorting with an explicit 32-character table — and
  the alphabet has 33 letters.
status: full
suite: 2 files, green
tested: 2026-09-15
license: GPL-3.0-or-later
depends: none beyond the core
raku-land: https://raku.land/zef:andmizyk/sortuk
source: https://gitlab.com/andmizyk/sortuk.git
---

## What it is for

Plain `.sort` on Ukrainian strings compares codepoints, and `і`, `ї` and `ґ`
sit far above the main Cyrillic block, so they are exiled to the end of the
list. This distribution sorts by the Ukrainian alphabet instead, folding case
as it goes.

Note the naming: the distribution is `sortuk`, lower-case, while the unit is
`SortUk`. Asking `rakupp test SortUk` answers "not in the store".

## Sorting

```raku name="basics"
use SortUk;

my @words = <абрикос банан ґанок евкаліпт ежак зебра іній їжак яблуко>;
say 'plain .sort : ', @words.reverse.sort.join(' ');
say 'sortuk      : ', sortuk(@words.reverse).join(' ');
say '';
say 'and it folds case, which plain .sort does not:';
my @mixed = <Яблуко абрикос Банан>;
say '  plain .sort : ', @mixed.sort.join('|');
say '  sortuk      : ', sortuk(@mixed).join('|');
say '';
say 'the return type is ', sortuk(@words).WHAT.^name, ', and the input array';
say 'is copied — your own list is untouched.';
```

```output
plain .sort : абрикос банан евкаліпт ежак зебра яблуко іній їжак ґанок
sortuk      : абрикос банан ґанок евкаліпт ежак зебра іній їжак яблуко

and it folds case, which plain .sort does not:
  plain .sort : Банан|Яблуко|абрикос
  sortuk      : абрикос|Банан|Яблуко

the return type is List, and the input array
is copied — your own list is untouched.
```

```raku name="candidates"
use SortUk;

say 'the proto has three candidates:';
say '  sortuk()           = ', sortuk().raku;
say '  sortuk("яблуко")   = ', sortuk('яблуко').raku;
say '  sortuk(@list)      returns a List';
say '';
say 'only the @data candidate carries `is export`, but exporting one';
say 'candidate exports the whole proto, so all three are reachable.';
say '';
my @orig = <в б а>;
my @out  = sortuk(@orig);
say 'input after the call  : ', @orig.join(',');
say 'output                : ', @out.join(',');
```

```output
the proto has three candidates:
  sortuk()           = ()
  sortuk("яблуко")   = ("яблуко",)
  sortuk(@list)      returns a List

only the @data candidate carries `is export`, but exporting one
candidate exports the whole proto, so all three are reachable.

input after the call  : в,б,а
output                : а,б,в
```

## The one thing to know

The alphabet constant is missing `ц`, and the module falls back to codepoint
order for any character it does not know — so words beginning with `ц` are
sorted as if the module were not there, against exactly the letters it exists
to fix.

```raku name="missing-ts"
use SortUk;

say 'the module`s alphabet has 32 characters; Ukrainian has 33.';
say '';
for <цап іній>, <цукор ґанок>, <цвях їжак> -> @pair {
    say sprintf('  %-16s plain=%-16s sortuk=%s',
                @pair.join(','), @pair.sort.join(','), sortuk(@pair).join(','));
}
say '';
say 'і is the 12th letter and ц the 27th, yet цап sorts before іній.';
say 'ґ is the 5th, yet ґанок sorts after цукор. In every one of those';
say 'cases sortuk`s answer is byte-for-byte the plain .sort answer — the';
say 'module silently does nothing.';
say '';
say 'cmp_ch only consults the table when BOTH characters are in it;';
say 'otherwise it compares .ord. ц happens to sort correctly against х';
say 'and ч only because their codepoints run in the right order.';
say '';
say 'and sorting the whole alphabet in reverse DOES come back in order,';
say 'which is exactly why this hides:';
my @alphabet = 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя'.comb;
say '  round trip holds : ', sortuk(@alphabet.reverse).join eq @alphabet.join;
```

```output
the module`s alphabet has 32 characters; Ukrainian has 33.

  цап,іній         plain=цап,іній         sortuk=цап,іній
  цукор,ґанок      plain=цукор,ґанок      sortuk=цукор,ґанок
  цвях,їжак        plain=цвях,їжак        sortuk=цвях,їжак

і is the 12th letter and ц the 27th, yet цап sorts before іній.
ґ is the 5th, yet ґанок sorts after цукор. In every one of those
cases sortuk`s answer is byte-for-byte the plain .sort answer — the
module silently does nothing.

cmp_ch only consults the table when BOTH characters are in it;
otherwise it compares .ord. ц happens to sort correctly against х
and ч only because their codepoints run in the right order.

and sorting the whole alphabet in reverse DOES come back in order,
which is exactly why this hides:
  round trip holds : True
```

## Prefixes are not ordered

```raku name="prefix"
use SortUk;

say 'the inner comparison loop stops at min(chars) and, finding no';
say 'difference, falls through without deciding:';
for ['банан', 'ба'], ['ба', 'банан'] -> @in {
    say sprintf('  input %-16s -> %s', @in.join(','), sortuk(@in).join(','));
}
say '';
say 'same data, other input order, other answer. It is not a total order.';
say '';
say 'and an empty string in the list is a landmine — sortuk([""]) reads';
say 'past the end of the array and calls .lc on it, which dies on both';
say 'engines. Filter empties out first:';
my @in = ('', 'абв', 'банан');
say '  filtered : ', sortuk(@in.grep(*.chars)).join(' ');
```

```output
the inner comparison loop stops at min(chars) and, finding no
difference, falls through without deciding:
  input банан,ба         -> банан,ба
  input ба,банан         -> ба,банан

same data, other input order, other answer. It is not a total order.

and an empty string in the list is a landmine — sortuk([""]) reads
past the end of the array and calls .lc on it, which dies on both
engines. Filter empties out first:
  filtered : абв банан
```

## Where the two engines differ

One case, and it is the empty-string one above: `sortuk(['', 'абв'])`
succeeds under Raku++ (answering `|абв`) and dies under Rakudo with
`X::TypeCheck::Binding::Parameter … expected Str but got Nil`. A single
empty string dies on both.

```raku name="cost"
use SortUk;

say 'the algorithm is an O(n²) bubble sort with an O(n) .comb inside the';
say 'comparison — it re-combs both words for every character comparison.';
say '';
my @words = (^40).map({ 'абвгґдеєжз'.comb.roll(6).join });
my $t = now;
my @sorted = sortuk(@words);
say '40 six-letter words sorted : ', @sorted.elems, ' back';
say '  in under a second        : ', (now - $t) < 1;
say '';
say 'fine for a menu or a glossary; not for a column of a database.';
say '';
say 'the shipped bin/sortuk takes the words as arguments, or one argument';
say 'that is an existing file, read line by line.';
```

```output
the algorithm is an O(n²) bubble sort with an O(n) .comb inside the
comparison — it re-combs both words for every character comparison.

40 six-letter words sorted : 40 back
  in under a second        : True

fine for a menu or a glossary; not for a column of a database.

the shipped bin/sortuk takes the words as arguments, or one argument
that is an existing file, read line by line.
```
