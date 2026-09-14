---
name: Text::Utils
version: 4.0.2
auth: zef:tbrowder
kind: Distribution · text
summary: A drawer of string chores — thousands separators, whitespace
  normalising, lists written out in English, comment stripping, substring
  counts and two kinds of line wrapping — each sub behind its own export
  tag.
status: full
suite: 18 files, green
tested: 2026-09-14
license: Artistic-2.0
depends: File::Temp, Font::AFM, AlgorithmsIT
raku-land: https://raku.land/zef:tbrowder/Text::Utils
source: https://github.com/tbrowder/Text-Utils
---

## What it is for

The small string jobs that every program ends up doing once, badly, in a
line of regex: putting commas into a number, collapsing runs of whitespace,
turning three items into "a, b, and c", cutting a `#` comment off a config
line, counting how often a substring occurs. This distribution collects a
dozen of them with names, and seventeen other distributions on raku.land
reach for it rather than rewriting them.

It is one author's drawer rather than a designed API, and the units under it
show that — `Text::Utils::Subs` holds the helpers the main unit is built
from, and the seventeen dependents mostly want `commify` or `strip-comment`.

## The chores

```raku name="chores"
use Text::Utils :ALL;

say commify(1234567);
say commify(1234567.891, :decimals(2));
say normalize-string("  a   b\t\tc  \n d ");
say normalize-string("a\t\tb  c", :c<s>).raku;
say list2text(<apples pears plums>);
say list2text(<apples pears plums>, :!optional-comma);
say count-substrs('banana', 'an');
say strip-comment('x = 1 # set x', :normalize).raku;
say strip-comment('x = 1 # set x', :save-comment).raku;
```

```output
1,234,567
1,234,567.89
a b c d
"a b c"
apples, pears, and plums
apples, pears and plums
2
"x = 1"
("x = 1 ", "# set x")
```

`normalize-string` trims and collapses whitespace by default and keeps tabs
and newlines as they are; `:c<s>` collapses every run, tabs included, to a
single space. `strip-comment` hands back the line with the comment gone and
its trailing space still there unless `:normalize` is on; with
`:save-comment` you get both halves. `list2text` writes the Oxford comma
unless told not to.

Wrapping comes in two flavours, and the names are close enough to mix up.
`wrap-paragraph` counts characters, which is what a terminal or a text file
wants:

```raku name="wrap"
use Text::Utils :wrap-paragraph;

my $t = 'The quick brown fox jumps over the lazy dog and keeps running far away from the farm';
.say for wrap-paragraph($t, :max-line-length(32));
```

```output
The quick brown fox jumps over
the lazy dog and keeps running
far away from the farm
```

`wrap-text` is not the same thing with a shorter name: its `:width` is in
**typographic points**, measured against a font from `Font::AFM` — it exists
for laying out text on a page, and asked to wrap a sentence at 30 it dies
with *Word 'brown' has length 30.36, too long for max line length of 30
points*. For anything that ends up in a terminal, `wrap-paragraph` is the one.

## The one thing to know

`use Text::Utils;` imports nothing. Every sub sits behind its own export
tag — `is export(:commify)`, `is export(:strip-comment)` and so on — so a plain
`use` compiles and leaves you with *Undeclared routine: commify* at the first
call. Either name the subs you want, `use Text::Utils :commify, :list2text;`,
or take the lot with `:ALL` as the first example does. The tags are the sub
names, which makes the selective form easy to write and also easy to forget
one of.
