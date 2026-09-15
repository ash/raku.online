---
name: Abbreviations
version: 2.2.3
auth: zef:tbrowder
kind: Distribution · text
summary: Every leading substring that identifies one word out of a set and
  no other — the unambiguous prefixes a command-line tool lets you type
  instead of the whole subcommand.
status: full
suite: 9 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:tbrowder/Abbreviations
source: https://github.com/tbrowder/Abbreviations
---

## What it is for

`git ci` is not a command; it is the shortest prefix of `commit` that no
other subcommand shares, and the program worked out which. Doing that for
your own word set is a small exercise in prefix trees that everyone writes
badly once: for each word, every leading substring that matches it and
nothing else. This distribution is that, with a choice of six shapes for
the answer.

## The shapes

```raku name="shapes"
use Abbreviations;

my @months = <January February March April May June July>;

my %shortest = abbreviations(@months);
say %shortest.keys.sort.map({ "$_=" ~ %shortest{$_} }).join(' ');

say abbreviations(@months, :out-type(AL)).sort.join(' ');

my %by-abbrev = abbreviations(@months, :out-type(AH));
say %by-abbrev.elems, ' abbreviations in all';
say %by-abbrev<Ja>, ' ', %by-abbrev<Jul>, ' ', %by-abbrev<Marc>;

my %all = abbreviations(@months, :out-type(H));
say %all<April>.join(',');
```

```output
April=A February=F January=Ja July=Jul June=Jun March=Mar May=May
A F Ja Jul Jun Mar May
27 abbreviations in all
January July March
A,Ap,Apr,Apri,April
```

The default shape, `HA`, maps each word to its **shortest** unambiguous
prefix, which is the one a help message wants to show. `AL` is the same
answers as a bare list. `AH` goes the other way, from every abbreviation to
the word it selects, which is the table a command dispatcher looks a typed
argument up in. `H` gives each word its full list, and `S` and `L` give
everything as a string or a sorted list.

`J` appears in none of them: three months begin with it, so it identifies
nothing and is not an abbreviation of anything. That is the whole point of
the exercise.

Two options shape the answer rather than its container. `:min-length`
raises the floor, so a set can be given prefixes that are all at least three
characters. `:lower-case` folds the words first, which changes not just the
case of the output but *which* prefixes are unambiguous.

## The one thing to know

With exactly one word in the set, `:out-type` is ignored and you get a
pipe-delimited string instead of the hash or list you asked for:

```raku name="one-word"
use Abbreviations;

my $one = abbreviations(<solo>, :out-type(HA));
say $one.^name, ' ', $one.raku;

my %two = abbreviations(<solo duet>, :out-type(HA));
say %two.^name, ' ', %two.keys.sort.map({ "$_=" ~ %two{$_} }).join(' ');

say (try abbreviations((), :out-type(HA))) // $!.message;
```

```output
Str "s|so|sol|solo"
Hash duet=d solo=s
FATAL: Empty input word set.
```

A caller that does `%result{$word}` on a word set that happens to have
shrunk to one entry gets nonsense rather than an error, and the shape only
changes back when a second word arrives. If the set is built at run time,
check its size before trusting the return type. An empty set at least fails
loudly.

One smaller thing worth knowing: `sort-list`, the companion that orders
strings by length and then text, is not in the default export. It needs
`use Abbreviations :ALL;`.
