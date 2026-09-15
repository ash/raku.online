---
name: Text::T9
version: 0.1
auth: zef:raku-community-modules
kind: Distribution · text
summary: Phone-keypad predictive text — given a digit string and a word list,
  the words that map to exactly that sequence.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: MIT
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Text::T9
source: https://github.com/raku-community-modules/Text-T9.git
---

## What it is for

On a numeric keypad `4663` could be *good*, *home*, *gone* or *hood* — every
letter on the `4` key, then every letter on the `6` key, and so on. T9 is the
input method that resolves that ambiguity against a dictionary.

This distribution is the filter half: you supply the candidate words, it
returns the ones whose letters map to exactly your digit sequence.

## Looking words up

```raku name="basics"
use Text::T9;

my @words = <good home gone hood hone goof book cook Good HOME re-do 4get>;
say 't9("4663", @words) : ', t9('4663', @words).List.raku;
say 't9(4663, @words)   : ', t9(4663, @words).List.raku, '   <- Str(Int) coercion';
say 't9("2665", @words) : ', t9('2665', @words).List.raku;
say '';
say 'the return type is ', t9('4663', @words).WHAT.^name;
say '';
say 'Good, HOME, re-do and 4get never match — only lowercase a..z are in';
say 'the keypad table, and an unmapped character silently makes the whole';
say 'word unmatchable rather than raising.';
```

```output
t9("4663", @words) : ("good", "home", "gone", "hood", "hone", "goof")
t9(4663, @words)   : ("good", "home", "gone", "hood", "hone", "goof")   <- Str(Int) coercion
t9("2665", @words) : ("book", "cook")

the return type is Seq

Good, HOME, re-do and 4get never match — only lowercase a..z are in
the keypad table, and an unmapped character silently makes the whole
word unmatchable rather than raising.
```

Length must match exactly; there is no prefix search.

```raku name="exact"
use Text::T9;

my @words = <good home>;
for '4663', '466', '46630', '' -> $d {
    say sprintf('  t9(%-8s) -> %s', $d.raku, t9($d, @words).List.raku);
}
say '';
say 'there is no entry for space, 0 or 1 in the table.';
```

```output
  t9("4663"  ) -> ("good", "home")
  t9("466"   ) -> ()
  t9("46630" ) -> ()
  t9(""      ) -> ()

there is no entry for space, 0 or 1 in the table.
```

## Extending the keypad

```raku name="extra"
use Text::T9;

my @words = <good Good GOOD home>;
say 'default          : ', t9('4663', @words).List.raku;
my %extra = G => 4, O => 6, D => 3;
say 'with %additional : ', t9('4663', @words, %extra).List.raku;
say '';
say 'the third argument MERGES with the built-in table, later wins — so';
say 'it both extends (uppercase) and overrides:';
my %override = a => 1, g => 1, o => 1, d => 1;
say '  t9("1111", ["good"], %override) = ', t9('1111', ['good'], %override).List.raku;
say '';
say 'and the alias export works the same way:';
say '  t9_find_words("4663", @words) = ', t9_find_words('4663', @words).List.raku;
```

```output
default          : ("good", "home")
with %additional : ("good", "Good", "GOOD", "home")

the third argument MERGES with the built-in table, later wins — so
it both extends (uppercase) and overrides:
  t9("1111", ["good"], %override) = ("good",)

and the alias export works the same way:
  t9_find_words("4663", @words) = ("good", "home")
```

## The one thing to know

`t9` returns a `Seq`, and under Rakudo a `Seq` can be walked exactly once — so
the obvious "count, then list" idiom throws.

```raku name="seq"
use Text::T9;

my @words = <good home gone>;

say 'the safe shape — cache it once:';
my @matches = t9('4663', @words).List;
say '  matches : ', @matches.elems;
say '  they are: ', @matches.join(' ');
say '  again   : ', @matches.join(' ');
say '';
say 'the unsafe one:';
say '  my $seq = t9("4663", @words);';
say '  say $seq.elems;      # walks it';
say '  say $seq.join(" ");  # X::Seq::Consumed on Rakudo';
say '';
say 'anything that touches the result twice — count then iterate, log then';
say 'use — passes on Raku++ and breaks on Rakudo. Call .List or .cache';
say 'once and work from that.';
```

```output
the safe shape — cache it once:
  matches : 3
  they are: good home gone
  again   : good home gone

the unsafe one:
  my $seq = t9("4663", @words);
  say $seq.elems;      # walks it
  say $seq.join(" ");  # X::Seq::Consumed on Rakudo

anything that touches the result twice — count then iterate, log then
use — passes on Raku++ and breaks on Rakudo. Call .List or .cache
once and work from that.
```

## Where the two engines differ

Exactly that: Raku++ lets a consumed `Seq` be re-iterated, Rakudo raises
`X::Seq::Consumed`. Reduced with no module involved, `my $s = (1,2,3).map(*+1)`
joined twice gives the same answer twice on one engine and throws on the
other.

```raku name="warnings"
use Text::T9;

my @words = <good home 4get>;
say 'matches : ', t9('4663', @words).List.join(' ');
say '';
say 'one more difference, in diagnostics rather than results: under Rakudo';
say 'this module prints a "Use of Nil in string context" warning to stderr';
say 'for every unmapped character it meets — 24 of them for the list above.';
say 'Raku++ prints none. The answers are identical either way, so filter';
say 'your word list to lowercase a..z if the noise matters.';
say '';
say '  filtered : ', t9('4663', @words.grep({ /^ <[a..z]>+ $/ })).List.join(' ');
```

```output
matches : good home

one more difference, in diagnostics rather than results: under Rakudo
this module prints a "Use of Nil in string context" warning to stderr
for every unmapped character it meets — 24 of them for the list above.
Raku++ prints none. The answers are identical either way, so filter
your word list to lowercase a..z if the noise matters.

  filtered : good home
```
