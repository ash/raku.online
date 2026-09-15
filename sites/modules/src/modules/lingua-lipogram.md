---
name: Lingua::Lipogram
version: 0.1.0
auth: github:sfischer13
kind: Distribution · linguistics
summary: Does this text avoid all of these letters? — one multi with five
  candidates, where `<ch>` and `('ch',)` mean completely different things.
status: full
suite: 3 files, green
tested: 2026-09-15
license: MIT
depends: Pod::To::Text (declared, unused, and not in the ecosystem index)
raku-land: https://raku.land/github:sfischer13/Lingua::Lipogram
source: git://github.com/sfischer13/perl6-Lingua-Lipogram.git
---

## What it is for

A lipogram is a text written without some letter. Georges Perec's *La
Disparition* is a novel with no `e` in it; constrained-writing puzzles and
word games are full of smaller ones. The question the form asks is always the
same: does this text avoid all of these characters?

This distribution answers exactly that question, case-insensitively, for a
string or for a file.

## Asking

```raku name="basics"
use Lingua::Lipogram;

say 'no "e" in "Lingua"      : ', lipogram('Lingua', 'e');
say 'but "e" is in "letter"  : ', lipogram('letter', 'e');
say 'case is folded          : ', lipogram('Elephant', 'e');
say '';
say 'several letters at once :';
say '  lipogram("rhythm", "aeiou") = ', lipogram('rhythm', 'aeiou');
say '  lipogram("syzygy", "aeiou") = ', lipogram('syzygy', 'aeiou');
say '';
say 'a Range works too       :';
say '  lipogram("xyz",  "a".."c") = ', lipogram('xyz',  'a'..'c');
say '  lipogram("xayz", "a".."c") = ', lipogram('xayz', 'a'..'c');
```

```output
no "e" in "Lingua"      : True
but "e" is in "letter"  : False
case is folded          : False

several letters at once :
  lipogram("rhythm", "aeiou") = True
  lipogram("syzygy", "aeiou") = True

a Range works too       :
  lipogram("xyz",  "a".."c") = True
  lipogram("xayz", "a".."c") = False
```

An empty letter set is vacuously true:

```raku name="empty"
use Lingua::Lipogram;

say q{lipogram('anything', '')  = }, lipogram('anything', '');
say q{lipogram('anything', ())  = }, lipogram('anything', ());
say '';
say 'the five candidates take (Str|IO::Path) x (Str|Range|Positional),';
say 'minus the IO::Path + Positional combination, which does not exist.';
```

```output
lipogram('anything', '')  = True
lipogram('anything', ())  = True

the five candidates take (Str|IO::Path) x (Str|Range|Positional),
minus the IO::Path + Positional combination, which does not exist.
```

## From a file

```raku name="file"
use Lingua::Lipogram;

my $f = $*TMPDIR.add("lipogram-{$*PID}.txt");
LEAVE $f.unlink;
$f.spurt("A quick brown fox jumps over a lazy dog.\n");

say 'no "z" in the file ? ', lipogram($f, 'z');
say 'no "o" in the file ? ', lipogram($f, 'o');
say '';
say 'there is no IO::Path + list candidate — only Str and Range:';
my $r = try lipogram($f, ('ing',));
say '  lipogram($path, ("ing",)) -> ', $! ?? 'no candidate matches' !! $r;
say '  slurp it yourself for the list form.';
```

```output
no "z" in the file ? False
no "o" in the file ? False

there is no IO::Path + list candidate — only Str and Range:
  lipogram($path, ("ing",)) -> no candidate matches
  slurp it yourself for the list form.
```

## The one thing to know

The `Str` argument is a set of **single letters**; the `Positional` argument
is a set of **substrings**. And `<ch>` is a `Str`, not a list — so the natural
spelling means something completely different from what it looks like.

```raku name="digraph"
use Lingua::Lipogram;

say '<ch> is a ', <ch>.WHAT.^name, ', <ch ap> is a ', <ch ap>.WHAT.^name;
say '';
say 'lipogram("the cap", <ch>)      = ', lipogram('the cap', <ch>),
    '   <- forbids "c" and "h" SEPARATELY, and both are present';
say 'lipogram("the cap", ("ch",))   = ', lipogram('the cap', ('ch',)),
    '   <- forbids the SUBSTRING "ch", which is absent';
say '';
say 'so a one-element angle list silently switches you from "no digraph"';
say 'to "neither of these two letters". Write ("ch",) or ["ch"].';
```

```output
<ch> is a Str, <ch ap> is a List

lipogram("the cap", <ch>)      = False   <- forbids "c" and "h" SEPARATELY, and both are present
lipogram("the cap", ("ch",))   = True   <- forbids the SUBSTRING "ch", which is absent

so a one-element angle list silently switches you from "no digraph"
to "neither of these two letters". Write ("ch",) or ["ch"].
```

## Where the two engines differ

Nothing in the library. The distribution ships a `bin/lipogram` script that
declares a dependency on `Pod::To::Text`, and that is where the engines part:
Rakudo bundles it in core, Raku++ does not, so the script dies there with
`Could not find Pod::To::Text` while the module itself — which never uses it —
is unaffected on both.

```raku name="portable"
use Lingua::Lipogram;

# the module is pure and portable; only the shipped script is not
my $perec = 'Un long fauteuil, un tapis, un mur blanc';
say 'text : ', $perec;
say '  avoids "e" ?      ', lipogram($perec, 'e');
say '  avoids "aeiou" ?  ', lipogram($perec, 'aeiou');
say '';
say 'and the inverse question, which this module does not answer —';
say 'which forbidden letters actually occur — is one grep away:';
say '  offenders : ',
    'aeiou'.comb.grep({ !lipogram($perec, $_) }).join(' ');
```

```output
text : Un long fauteuil, un tapis, un mur blanc
  avoids "e" ?      False
  avoids "aeiou" ?  False

and the inverse question, which this module does not answer —
which forbidden letters actually occur — is one grep away:
  offenders : a e i o u
```
