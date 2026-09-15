---
name: Glob::Grammar
version: 0.0.2
auth: zef:wayland
kind: Distribution · text
summary: A grammar for shell wildcard syntax, with an actions class that
  translates a glob into the source text of a Raku regex.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:wayland/Glob::Grammar
source: https://github.com/wayland/Glob-Grammar
---

## What it is for

Users know `*.txt`. They do not know `/ '.txt' $ /`, and asking them to
learn it for a filter box or a configuration key is the wrong trade. A
program that accepts glob patterns has to turn them into something it can
match with, and this distribution is the smallest possible answer: a
six-token grammar for the syntax, and an actions class that emits the
equivalent regex as a string.

It is two files and thirty-four lines, which is worth knowing before
reaching for it — the whole thing is small enough to read in a minute, and
its limits follow from that.

## Glob in, regex source out

```raku name="translate"
use Glob::Grammar;
use Glob::ToRegexActions;

my $actions = Glob::ToRegexActions.new;
sub to-rx(Str $glob) {
    my $m = Glob::Grammar.parse($glob, :$actions);
    $m ?? $m.made !! Nil
}

for '*.txt', 'a?c', 'README', 'src/*.rakumod' -> $g {
    say sprintf('%-14s %s', $g, to-rx($g).raku);
}

my $rx = to-rx('*.txt');
say $rx.^name;
for <notes.txt notes.md a.txt txt> -> $name {
    say sprintf('  %-10s %s', $name, so $name ~~ /<$rx>/);
}
```

```output
*.txt          "^.*\\.txt\$"
a?c            "^a.c\$"
README         "^README\$"
src/*.rakumod  "^src\\/.*\\.rakumod\$"
Str
  notes.txt  True
  notes.md   False
  a.txt      True
  txt        False
```

`*` becomes `.*`, `?` becomes `.`, and every other character is escaped so
it matches itself. The result is a `Str`, not a `Regex` — you interpolate
it with `/<$rx>/`, and because it is anchored at both ends it always does
whole-string matching.

## The one thing to know

A bracket group is not translated as a character class in the shell sense.
The members are stringified with spaces between them, so a range is not a
range and a negation is not a negation:

```raku name="brackets"
use Glob::Grammar;
use Glob::ToRegexActions;

my $actions = Glob::ToRegexActions.new;
sub to-rx(Str $g) {
    my $m = Glob::Grammar.parse($g, :$actions);
    $m ?? $m.made !! Nil
}

say to-rx('[abc]x').raku;
say to-rx('[a-c]x').raku;
say to-rx('[!a]bc').raku;
say to-rx('{one,two}').raku;
say to-rx('a\*b').raku;
```

```output
"^<[a b c]>x\$"
"^<[a - c]>x\$"
"^<[! a]>bc\$"
"^\\\{one\\,two\\}\$"
"^a\\\\.*b\$"
```

A plain list of characters works, which covers most real patterns. The
second line is a range in every shell and is the literal three-member set
`a`, `-`, `c` here — so `bx` does not match and `-x` does. The third is
shell negation and matches `abc` while rejecting `xbc`, exactly inverted.
Brace alternation is not glob syntax to this grammar at all, and a
backslash does not escape anything, so a literal `*` cannot be matched.

Within a plain wildcard pattern the translation is sound. Anything with
brackets or braces in it needs checking against what you meant.

## Where the two engines differ

The generated string is Raku source, and the two engines do not accept
quite the same Raku. `<[a - c]>` — what a range turns into — is a
character class with a literal hyphen under Raku++ and a compile error
under Rakudo, which refuses a bare `-` inside a class. A glob containing a
space becomes an escaped space, which Raku++ accepts and Rakudo rejects as
an unspace. And `\w` differs on non-ASCII letters, so an accented character
is escaped by one engine and not the other.

The failures surface at *match* time rather than at translation time,
because the illegal construct is inside an interpolated string. If the
patterns come from users and the code has to run on both engines, restrict
the accepted syntax to `*`, `?` and plain bracket lists, and reject the
rest before translating.
