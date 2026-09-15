---
name: Text::Lorem
version: 1.0.1
auth: zef:slavenskoj
kind: Distribution · test data
summary: Lorem-ipsum words, sentences and paragraphs from a 184-slot
  vocabulary — sampled without replacement, so a long request is truncated.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:slavenskoj/Text::Lorem
source: https://github.com/slavenskoj/raku-text-lorem.git
---

## What it is for

Placeholder prose: filler for a layout, a fixture for a text-processing test,
something plausible-looking to put in a database while you build the thing
that will hold the real content.

`Text::Lorem` is a class holding a fixed list of lorem-ipsum words and three
methods that sample from it.

## The three methods

```raku name="basics"
use Text::Lorem;

my $l = Text::Lorem.new;

my $w = $l.words(5);
say 'words(5)      : ', $w.words.elems, ' words, ends with a full stop? ', $w.ends-with('.');
say '                capitalised? ', ($w ~~ /^<:Lu>/).so;

my $s = $l.sentences(3);
say 'sentences(3)  : ', $s.split('. ').elems, ' sentences';
say '                every sentence Titlecased? ',
    $s.split('. ').map({ so /^<:Lu>/ }).all.so;

my $p = $l.paragraphs(2);
say 'paragraphs(2) : ', $p.split("\n\n").elems, ' paragraphs, separated by a blank line';
```

```output
words(5)      : 5 words, ends with a full stop? True
                capitalised? False
sentences(3)  : 3 sentences
                every sentence Titlecased? True
paragraphs(2) : 2 paragraphs, separated by a blank line
```

The output is random and cannot be seeded — there is no `:seed` parameter and
no way to inject an RNG — so anything you assert about it has to be a shape,
not a value. Sentences hold 5 to 15 words; paragraphs hold 3 to 7 sentences.

All three are **instance** methods. The type-object call fails at run time,
not compile time:

```raku name="instance"
use Text::Lorem;

my $r = try Text::Lorem.words(3);
say 'Text::Lorem.words(3) without .new -> ', $! ?? 'threw' !! $r;
say 'Text::Lorem.new.words(3)          -> ', Text::Lorem.new.words(3).words.elems, ' words';
```

```output
Text::Lorem.words(3) without .new -> threw
Text::Lorem.new.words(3)          -> 3 words
```

## The odd one out

`words` behaves differently from its two siblings in every way: it does not
capitalise, and it punctuates an empty request where the others return the
empty string.

```raku name="zero"
use Text::Lorem;

my $l = Text::Lorem.new;
say 'words(0)      : ', $l.words(0).raku;
say 'sentences(0)  : ', $l.sentences(0).raku;
say 'paragraphs(0) : ', $l.paragraphs(0).raku;
```

```output
words(0)      : "."
sentences(0)  : ""
paragraphs(0) : ""
```

## The one thing to know

`words` samples **without replacement**. Ask for more words than the built-in
vocabulary holds and you silently get the vocabulary, with no error, no
warning and no repetition.

```raku name="cap"
use Text::Lorem;

my $l = Text::Lorem.new;
say 'vocabulary slots : ', $l.lorem-words.elems;
say 'distinct values  : ', $l.lorem-words.unique.elems;
say '';
for 5, 50, 184, 200, 1000 -> $n {
    say sprintf('words(%4d) -> %d words', $n, $l.words($n).words.elems);
}
say '';
say 'a 500-word placeholder block — the obvious use for a lorem-ipsum';
say 'module — gets you 184 words and a full stop, and a length assertion';
say 'in a test fails with no clue why.';
```

```output
vocabulary slots : 184
distinct values  : 146

words(   5) -> 5 words
words(  50) -> 50 words
words( 184) -> 184 words
words( 200) -> 184 words
words(1000) -> 184 words

a 500-word placeholder block — the obvious use for a lorem-ipsum
module — gets you 184 words and a full stop, and a length assertion
in a test fails with no clue why.
```

Note the second line too: 184 slots hold only 146 distinct values (`et`
appears ten times, `est` five, `ut` four), so `pick` can and does return the
same word more than once. The output is not a set.

`sentences` and `paragraphs` are unaffected, because their internal lengths
are capped at 15.

## Where the two engines differ

One case, and it is the negative-count one. `@.lorem-words` is a public
attribute you can set through `.new`, which is the only extension point:

```raku name="vocabulary"
use Text::Lorem;

my $tiny = Text::Lorem.new(lorem-words => <alpha beta gamma>);
say 'a three-word vocabulary, asked for three words:';
say '  ', $tiny.words(3).subst(/'.'$/, '').words.sort.join(' '), ' plus a full stop';
say '';
say 'asked for ten:';
say '  ', $tiny.words(10).words.elems, ' words — the cap again, at 3 this time';
```

```output
a three-word vocabulary, asked for three words:
  alpha beta gamma plus a full stop

asked for ten:
  3 words — the cap again, at 3 this time
```

`words(-1)` returns `"."` under Raku++ and throws `Coercion to UInt out of
range. Is: -1, should be in 0..^Inf` under Rakudo. `.pick` is where the
difference lives: Rakudo's refuses a negative count, Raku++'s returns an empty
sequence. Guard the count yourself and the two engines agree everywhere else.
