---
name: UK::Sort
version: 0.0.1
auth: zef:andm
kind: Distribution · localisation
summary: Ukrainian dictionary order — and not a thin wrapper around `coll`,
  because `coll` gets і, ї and й wrong.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:andm/UK::Sort
source: https://gitlab.com/andmizyk/UK-Sort.git
---

## What it is for

Sorting Ukrainian strings the way a Ukrainian dictionary does. Plain `.sort`
compares codepoints, and Ukrainian's `і`, `ї` and `ґ` live far above the main
Cyrillic block, so they land at the end of the list instead of in their proper
places.

## Sorting

```raku name="basics"
use UK::Sort;

my @words = <яблуко абрикос ґанок зебра іній їжак евкаліпт ежак банан>;
say 'plain .sort : ', @words.sort.join(' ');
say 'sortuk      : ', sortuk(@words).join(' ');
say '';
say 'and it folds case, which plain .sort does not:';
my @mixed = <Яблуко абрикос Банан>;
say '  plain .sort : ', @mixed.sort.join(' ');
say '  sortuk      : ', sortuk(@mixed).join(' ');
```

```output
plain .sort : абрикос банан евкаліпт ежак зебра яблуко іній їжак ґанок
sortuk      : абрикос банан ґанок евкаліпт ежак зебра іній їжак яблуко

and it folds case, which plain .sort does not:
  plain .sort : Банан Яблуко абрикос
  sortuk      : абрикос Банан Яблуко
```

The whole alphabet, shuffled and put back:

```raku name="alphabet"
use UK::Sort;

my @alphabet = 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя'.comb;
my @shuffled = @alphabet.reverse;
say 'official order : ', @alphabet.join(' ');
say 'sortuk of it   : ', sortuk(@shuffled).join(' ');
say 'matches        : ', sortuk(@shuffled).join eq @alphabet.join;
```

```output
official order : а б в г ґ д е є ж з и і ї й к л м н о п р с т у ф х ц ч ш щ ь ю я
sortuk of it   : а б в г ґ д е є ж з и і ї й к л м н о п р с т у ф х ц ч ш щ ь ю я
matches        : True
```

## The comparator

```raku name="cmp"
use UK::Sort;

say 'cmp_uk is exported too — note the underscore, not a hyphen:';
for <абрикос банан>, <ґанок абрикос>, <іній їжак>, <банан банан> -> ($a, $b) {
    say sprintf('  cmp_uk(%-10s, %-10s) = %s', $a.raku, $b.raku, cmp_uk($a, $b));
}
say '';
say 'sortuk has three candidates:';
say '  sortuk()          = ', sortuk().raku;
say '  sortuk("яблуко")  = ', sortuk('яблуко').raku;
say '  sortuk(@list)     returns a Seq';
say '';
say 'a single string is silently treated as a one-element list rather';
say 'than being an error.';
```

```output
cmp_uk is exported too — note the underscore, not a hyphen:
  cmp_uk("абрикос" , "банан"   ) = Less
  cmp_uk("ґанок"   , "абрикос" ) = More
  cmp_uk("іній"    , "їжак"    ) = Less
  cmp_uk("банан"   , "банан"   ) = Same

sortuk has three candidates:
  sortuk()          = ()
  sortuk("яблуко")  = ("яблуко",)
  sortuk(@list)     returns a Seq

a single string is silently treated as a one-element list rather
than being an error.
```

## The one thing to know

This is not a thin wrapper around `coll`, and you cannot replace it with
`@list.sort(&[coll])`. A whole-string `coll` treats `і`, `ї` and `й` as the
same primary letter with a diacritic, so it keeps scanning past them and lets
a later letter decide — which is wrong for Ukrainian, where those are three
separate letters of the alphabet.

```raku name="coll"
use UK::Sort;

my @w = <їжак іній ирій йод>;
say 'sortuk         : ', sortuk(@w).join(' ');
say 'sort(&[coll])  : ', @w.sort(&[coll]).join(' ');
say 'plain .sort    : ', @w.sort.join(' ');
say '';
say 'cmp_uk("їжак","іній") = ', cmp_uk('їжак', 'іній'),
    '    "їжак" coll "іній" = ', ('їжак' coll 'іній');
say '';
say 'the two disagree, and cmp_uk is the one that is right: ї is the';
say '13th letter and і the 12th, so іній must come first. cmp_uk`s';
say 'letter-at-a-time loop forces each letter`s full weight to settle';
say 'before moving on; coll does not.';
```

```output
sortuk         : ирій іній їжак йод
sort(&[coll])  : ирій їжак іній йод
plain .sort    : ирій йод іній їжак

cmp_uk("їжак","іній") = More    "їжак" coll "іній" = Less

the two disagree, and cmp_uk is the one that is right: ї is the
13th letter and і the 12th, so іній must come first. cmp_uk`s
letter-at-a-time loop forces each letter`s full weight to settle
before moving on; coll does not.
```

Across 91 pairs sampled from the alphabet, that is the only class of
disagreement between `cmp_uk` and `coll` — and every one of them is a case
where `coll` is wrong for Ukrainian.

## Where the two engines differ

Only in *when* a type error is reported. `cmp_uk` is `Str`-only, and passing
numbers is a run-time failure under Raku++ and a compile-time refusal under
Rakudo — so a `try` around it helps on one engine and not the other.

```raku name="types"
use UK::Sort;

# coerce at the call site and both engines agree
my @numbers = 10, 2, 33;
say 'numbers, stringified then sorted : ',
    sortuk(@numbers.map(*.Str)).join(' ');
say '';
say 'cmp_uk(10, 2) without the .Str is a run-time X::TypeCheck on Raku++';
say 'and "===SORRY!=== Calling cmp_uk(Int, Int) will never work" on Rakudo,';
say 'which no `try` can catch. Stringify before you sort.';
say '';
say 'the two shipped scripts, sortuk and sortuk-lib.raku, take the words';
say 'as arguments or a single argument that is an existing file. Note that';
say 'sortuk-lib.raku begins with `use lib "lib"`, so running it creates a';
say 'lib/.precomp directory wherever you happen to be.';
```

```output
numbers, stringified then sorted : 10 2 33

cmp_uk(10, 2) without the .Str is a run-time X::TypeCheck on Raku++
and "===SORRY!=== Calling cmp_uk(Int, Int) will never work" on Rakudo,
which no `try` can catch. Stringify before you sort.

the two shipped scripts, sortuk and sortuk-lib.raku, take the words
as arguments or a single argument that is an existing file. Note that
sortuk-lib.raku begins with `use lib "lib"`, so running it creates a
lib/.precomp directory wherever you happen to be.
```
