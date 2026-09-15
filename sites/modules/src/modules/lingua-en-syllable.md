---
name: Lingua::EN::Syllable
version: 1.0.3
auth: zef:coke
kind: Distribution · text
summary: Estimate how many syllables an English word has, by counting vowel
  groups and applying a list of corrective patterns.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:coke/Lingua::EN::Syllable
source: git://github.com/coke/raku-lingua-en-syllable.git
---

## What it is for

Every readability score — Flesch, Flesch–Kincaid, Gunning fog, SMOG — is
words per sentence and syllables per word. The second half needs a syllable
count, and a dictionary lookup is both too slow and too incomplete for
arbitrary text.

This distribution is the heuristic version: count the vowel groups, then apply
a list of corrections for the patterns English uses to break the rule.

## Counting syllables

```raku name="syllable"
use Lingua::EN::Syllable;

for <cat table syllable beautiful university Mississippi
     strength onomatopoeia> -> $w {
    say sprintf('%-16s => %d', $w, syllable($w));
}
```

```output
cat              => 1
table            => 2
syllable         => 3
beautiful        => 4
university       => 5
Mississippi      => 4
strength         => 1
onomatopoeia     => 7
```

Most of those are right. `table` is two, `beautiful` four, `university` five,
`Mississippi` four, `strength` one.

## Case and punctuation

```raku name="input"
use Lingua::EN::Syllable;

for <banana Banana BANANA> -> $w {
    say sprintf('%-10s => %d', $w, syllable($w));
}
say '';
for "don't", 'hello-world', 'co-operate' -> $w {
    say sprintf('%-14s => %d', $w.raku, syllable($w));
}
```

```output
banana     => 3
Banana     => 3
BANANA     => 3

"don't"        => 1
"hello-world"  => 3
"co-operate"   => 4
```

Case is folded correctly. Hyphenated input is counted as a **whole**, which is
right for `hello-world` and means the routine is not purely per-word — feed it
tokens, not phrases.

## The one thing to know

The function has a floor of 1 and never returns 0, including for input
containing no letters at all.

```raku name="floor-trap"
use Lingua::EN::Syllable;

for '', '   ', '123', '---', '42.7' -> $w {
    say sprintf('%-10s => %d', $w.raku, syllable($w));
}
say '';
say 'there is no return value that means "I could not analyse this"';
```

```output
""         => 1
"   "      => 1
"123"      => 1
"---"      => 1
"42.7"     => 1

there is no return value that means "I could not analyse this"
```

The most common use of a syllable counter is a readability score computed over
a tokenised document — and a tokeniser that leaves numbers, punctuation
fragments or empty strings in the stream will silently inflate the total by
one per junk token. That bias lands directly on the metric, and the metric is
the only thing you were computing.

Filter the token stream yourself: skip anything without a letter in it.

## Where the two engines differ

Nowhere. Every word, every edge case and every case variant produced identical
output on Raku++ and Rakudo, with no exception raised for any input tested.

The accuracy is what you would expect from a vowel-group heuristic, and the
errors are not symmetric. Two worth knowing:

```raku name="accuracy"
use Lingua::EN::Syllable;

for 'queue'   => 1,
    'rhythm'  => 2,
    'onomatopoeia' => 6,
    'cat'     => 1,
    'table'   => 2 -> $p {
    my $got = syllable($p.key);
    say sprintf('%-14s counted %d, actually %d  %s',
        $p.key, $got, $p.value, $got == $p.value ?? 'ok' !! 'off');
}
```

```output
queue          counted 2, actually 1  off
rhythm         counted 1, actually 2  off
onomatopoeia   counted 7, actually 6  off
cat            counted 1, actually 1  ok
table          counted 2, actually 2  ok
```

`queue` has one syllable and counts as two — four vowels in a row defeat the
grouping. `rhythm` has two and counts as one, because it has no written vowel
at all. Over a document those errors partly cancel, which is why the heuristic
is good enough for a readability score and not good enough for anything that
needs a per-word answer.
