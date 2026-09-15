---
name: Lingua::Pangram
version: 0.1.1
auth: github:sfischer13
kind: Distribution · linguistics
summary: Does this text use every required character? — with five per-language
  wrappers, one of which tests for `ss` when it means `ß`.
status: full
suite: 4 files, green
tested: 2026-09-15
license: MIT
depends: Pod::To::Text (declared, unused, and not in the ecosystem index)
raku-land: https://raku.land/github:sfischer13/Lingua::Pangram
source: git://github.com/sfischer13/perl6-Lingua-Pangram.git
---

## What it is for

A pangram uses every letter of an alphabet at least once. *The quick brown
fox jumps over the lazy dog* is the English one; font specimens, keyboard
tests and typing drills all want them.

This distribution checks the property for any alphabet you supply, and ships
five wrappers that pin the alphabet for English, German, Spanish, French and
Russian.

## Checking

```raku name="basics"
use Lingua::Pangram;

my $fox = 'The quick brown fox jumps over the lazy dog';
say 'pangram-en(the fox)        : ', pangram-en($fox);
say 'pangram-en(missing the q)  : ', pangram-en($fox.subst('quick', 'swift'));
say 'case is folded             : ', pangram-en($fox.uc);
say 'pangram-en("")             : ', pangram-en('');
say '';
say 'the generic form takes a string of characters, a Range, or a list:';
say '  pangram($fox, "abc")         = ', pangram($fox, 'abc');
say '  pangram($fox, "a".."z")      = ', pangram($fox, 'a'..'z');
say '  pangram($fox, <q u i c k>)   = ', pangram($fox, <q u i c k>);
```

```output
pangram-en(the fox)        : True
pangram-en(missing the q)  : False
case is folded             : True
pangram-en("")             : False

the generic form takes a string of characters, a Range, or a list:
  pangram($fox, "abc")         = True
  pangram($fox, "a".."z")      = True
  pangram($fox, <q u i c k>)   = True
```

Matching is by substring after foldcasing both sides, so multi-character
graphs work as well as single letters — and the Russian wrapper is right:

```raku name="russian"
use Lingua::Pangram;

my $ru = "\c[CYRILLIC SMALL LETTER A]".."\c[CYRILLIC SMALL LETTER YA]";
say 'the contiguous Cyrillic block "а".."я" holds ', $ru.elems, ' letters';
say '  plus ё separately makes the full 33.';
say '';
my $text = 'Съешь же ещё этих мягких французских булок, да выпей чаю';
say 'pangram-ru(a known Russian pangram) : ', pangram-ru($text);
say 'pangram-ru(the same, ё removed)     : ', pangram-ru($text.subst('ё', 'е', :g));
```

```output
the contiguous Cyrillic block "а".."я" holds 32 letters
  plus ё separately makes the full 33.

pangram-ru(a known Russian pangram) : True
pangram-ru(the same, ё removed)     : False
```

## The one thing to know

`pangram-de`'s test for `ß` is really a test for `ss`, because both sides are
foldcased and `'ß'.fc` is `'ss'`.

```raku name="sharp-s"
use Lingua::Pangram;

my $de = 'Victor jagt zwölf Boxkämpfer quer über den großen Sylter Deich';
say 'with a real ß  : ', pangram-de($de);
say 'ß spelled ss   : ', pangram-de($de.subst("\c[LATIN SMALL LETTER SHARP S]", 'ss'));
say 'no ß and no ss : ', pangram-de($de.subst("gro\c[LATIN SMALL LETTER SHARP S]en", 'groben'));
say '';
say 'a German text in Swiss orthography — which never uses ß — passes as';
say 'a German pangram, and there is no way to demand the actual character.';
```

```output
with a real ß  : True
ß spelled ss   : True
no ß and no ss : False

a German text in Swiss orthography — which never uses ß — passes as
a German pangram, and there is no way to demand the actual character.
```

## The alphabets the wrappers pin

```raku name="wrappers"
use Lingua::Pangram;

my $es = 'Benjamín pidió una bebida de kiwi y fresa; noté que佐 exhausto '
       ~ 'chef vomitó justo sobre el zueco lleno de whisky';
say 'pangram-es(a standard Spanish pangram)             : ', pangram-es($es);
say 'pangram-es(the same, :digraphs)                    : ', pangram-es($es, True);
say '';
say ':digraphs demands ch, ll AND rr. The RAE struck ch and ll from the';
say 'Spanish alphabet in 1994, and rr has never been a letter of it — so';
say 'the flag rejects the very texts it exists to accept.';
say '';
my $fr = 'Portez ce vieux whisky au juge blond qui fume';
say 'pangram-fr(a standard French pangram)              : ', pangram-fr($fr);
say 'pangram-fr(the same, :ligatures)                   : ', pangram-fr($fr, True);
say '';
say ':ligatures demands both æ and œ, which no common French pangram has.';
```

```output
pangram-es(a standard Spanish pangram)             : False
pangram-es(the same, :digraphs)                    : False

:digraphs demands ch, ll AND rr. The RAE struck ch and ll from the
Spanish alphabet in 1994, and rr has never been a letter of it — so
the flag rejects the very texts it exists to accept.

pangram-fr(a standard French pangram)              : True
pangram-fr(the same, :ligatures)                   : False

:ligatures demands both æ and œ, which no common French pangram has.
```

## Where the two engines differ

Nothing in the library — the same five wrappers, the same alphabets, the same
verdicts. Only the shipped `bin/pangram` script diverges, on the
`Pod::To::Text` dependency that Rakudo carries in core and Raku++ does not.

The trap worth carrying away is the one it shares with `Lingua::Lipogram`:
a one-element angle list is a `Str`, not a list, and the two mean opposite
things here.

```raku name="digraph"
use Lingua::Pangram;

say 'pangram("the cap", <ch>)     = ', pangram('the cap', <ch>),
    '   <- requires "c" and "h" separately: both present';
say 'pangram("the cap", ("ch",))  = ', pangram('the cap', ('ch',)),
    '   <- requires the substring "ch": absent';
say '';
say 'and an empty requirement is vacuously true, while an empty text is not:';
say '  pangram("anything", ())  = ', pangram('anything', ());
say '  pangram-en("")           = ', pangram-en('');
```

```output
pangram("the cap", <ch>)     = True   <- requires "c" and "h" separately: both present
pangram("the cap", ("ch",))  = False   <- requires the substring "ch": absent

and an empty requirement is vacuously true, while an empty text is not:
  pangram("anything", ())  = True
  pangram-en("")           = False
```
