---
name: Text::Wrap
version: 0.0.5
auth: zef:jkramer
kind: Distribution · text
summary: One sub that folds a string to a width — paragraphs kept apart,
  a prefix per line if you want one, and long words either left whole or
  cut — for text that is going to a terminal or a plain-text file.
status: full
suite: 5 files, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/zef:jkramer/Text::Wrap
source: https://codeberg.org/jkramer/raku-text-wrap
---

## What it is for

A help text, a commit message, an email body: prose that has to fit in
eighty columns and was written as one long line. Folding it is a loop over
words with a running count, plus the two cases everyone forgets — a blank
line between paragraphs that must survive, and a word longer than the
width. This distribution is that loop with both cases handled, as a single
sub with keyword options, and four distributions use it rather than
carrying their own.

## Folding

```raku name="wrap"
use Text::Wrap;

my $t = 'The quick brown fox jumps over the lazy dog and keeps running far away from the farm';
say wrap-text($t, :width(32));
say wrap-text($t, :width(32), :prefix('> '));
say wrap-text("first paragraph here\n\nsecond one", :width(12));
say wrap-text('supercalifragilisticexpialidocious word', :width(10), :hard-wrap);
```

```output
The quick brown fox jumps over
the lazy dog and keeps running
far away from the farm
> The quick brown fox jumps over
> the lazy dog and keeps running
> far away from the farm
first
paragraph
here

second one
supercalif
ragilistic
expialidoc
ious word
```

The default width is 80. A blank line in the input ends a paragraph and is
kept; the regex that decides what a paragraph break looks like is the
`:paragraph` option, for input that separates them some other way. A
`:prefix` goes on every line, a `:postfix` at every line's end.

## The one thing to know

The prefix is not counted. The three `> ` lines above break in exactly the
same places as the three without, so each is two characters *wider* than
the width you asked for — 32 becomes 34 on the screen. When the width is a
real limit (a terminal, a mail transport's line length), subtract the
prefix from it yourself.

And a word longer than the width is left whole unless `:hard-wrap` is on:
the default keeps words intact and lets the line overflow, which is right
for a URL and wrong for a table cell. `:hard-wrap` cuts at the width, as
the last four lines show, with no hyphen and no regard for syllables.
