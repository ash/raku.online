---
name: Grammar::TodoTxt
version: 0.1.0
auth: none stated
kind: Distribution · grammars
summary: A grammar for the todo.txt task format — completion marker, priority,
  two dates, and a description in which projects, contexts and key:value
  labels are picked out from ordinary words.
status: full
suite: 4 files, green
tested: 2026-09-15
license: AGPL-3.0
depends: none beyond the core
raku-land: https://raku.land/?/Grammar::TodoTxt
source: https://home.tyil.nl/git/raku/Grammar::TodoTxt/
---

## What it is for

todo.txt is a plain-text task format with just enough structure to be useful:
one task per line, an optional `x` to mark it done, an optional `(A)`
priority, up to two dates, and a description in which `+project` and `@context`
tags are conventional. Its whole appeal is that the file stays readable in any
editor.

This distribution is the grammar. There are no action classes, so you read the
results straight off the `Match`.

## Parsing a file

```raku name="parse"
use Grammar::TodoTxt;

my $todo = q:to/END/;
(A) 2021-03-04 Call Mum +family @phone due:2021-03-05
x 2021-05-06 2021-03-04 Pay the rent +home @bank
Buy milk @shop
END

my $m = Grammar::TodoTxt.parse($todo);
say 'parsed  : ', ?$m;
say 'records : ', $m<records>.elems;
say '';
for $m<records>.kv -> $i, $r {
    say "record $i";
    say '  done       : ', $r<completion-marker>.defined ?? 'yes' !! 'no';
    say '  priority   : ', $r<priority>.defined ?? ~$r<priority> !! '(none)';
    say '  completion : ', $r<completion>.defined ?? ~$r<completion> !! '(none)';
    say '  creation   : ', $r<creation>.defined   ?? ~$r<creation>   !! '(none)';
    say '  projects   : ', ($r<description><projects> // ()).map(*.Str).join(',') || '(none)';
    say '  contexts   : ', ($r<description><contexts> // ()).map(*.Str).join(',') || '(none)';
    say '  labels     : ', ($r<description><labels> // ()).map({ "{$_<key>}={$_<value>}" }).join(',') || '(none)';
    say '  words      : ', ($r<description><words> // ()).map(*.Str).join(' ');
}
```

```output
parsed  : True
records : 3

record 0
  done       : no
  priority   : A
  completion : (none)
  creation   : 2021-03-04
  projects   : family
  contexts   : phone
  labels     : due=2021-03-05
  words      : Call Mum
record 1
  done       : yes
  priority   : (none)
  completion : 2021-05-06
  creation   : 2021-03-04
  projects   : home
  contexts   : bank
  labels     : (none)
  words      : Pay the rent
record 2
  done       : no
  priority   : (none)
  completion : (none)
  creation   : (none)
  projects   : (none)
  contexts   : shop
  labels     : (none)
  words      : Buy milk
```

The `<( … )>` captures inside the grammar mean the interesting pieces come
back clean: `<priority>` yields just `A`, `<context>` just the word after the
`@`, `<project>` just the word after the `+`, and `<date>` just the digits.

## What it accepts

```raku name="edges"
use Grammar::TodoTxt;

for "", "\n", "   \n", "(A)\n", "x\n", "just some words\n" -> $s {
    say sprintf('parse %-12s -> %s', $s.raku,
        Grammar::TodoTxt.parse($s) ?? 'ok' !! 'no match');
}
```

```output
parse ""           -> no match
parse "\n"         -> ok
parse "   \n"      -> no match
parse "(A)\n"      -> ok
parse "x\n"        -> ok
parse "just some words\n" -> ok
```

A blank line parses; a whitespace-only line does not; the empty string does
not. So a todo file that ends without a newline, or that has a space-padded
blank line in it, fails whole-file `.parse` with no indication of where.

## The one thing to know

Any word containing a colon is captured as a `key:value` label, so URLs and
clock times become metadata.

```raku name="colon-trap"
use Grammar::TodoTxt;

for "Read https://example.com/docs\n", "Meet at 10:30\n", "Fix c:\\path\\thing\n" -> $line {
    my $r = Grammar::TodoTxt.parse($line)<records>[0];
    say 'line   : ', $line.chomp;
    say '  labels : ', ($r<description><labels> // ()).map({ "{$_<key>} => {$_<value>}" }).join(' | ') || '(none)';
    say '  words  : ', ($r<description><words> // ()).map(*.Str).join(' ') || '(none)';
}
```

```output
line   : Read https://example.com/docs
  labels : https => //example.com/docs
  words  : Read
line   : Meet at 10:30
  labels : 10 => 30
  words  : Meet at
line   : Fix c:\path\thing
  labels : c => \path\thing
  words  : Fix
```

The `label` token is `<key> ':' <value>` with `key` as `<[\w-]>+`, and the
description alternation tries `label` before `word`. Nothing restricts it to
the small tag vocabulary todo.txt intends. A tool that iterates `<labels>` to
build a tag index picks up every link and every time-of-day in the file as a
tag — and the affected token **disappears from `<words>`**, so a naive
"reconstruct the description" pass loses it too.

Filter the labels against a known key list, and rebuild descriptions from the
record's own `.Str` rather than from `<words>`.

## Where the two engines differ

Nowhere. Every spike in this page produced byte-identical output under Raku++
and Rakudo, down to the `｢…｣` Match markers.

One more thing that is not an engine difference and will bite. A **single**
date after `x` is filed as `creation`, not `completion`. The record rule is
`[ <completion=.date>? <creation=.date> ]?`, so the mandatory member of the
pair is `creation` and with one date present it wins — while the todo.txt
convention is that the date immediately after `x` is the completion date. Only
when two dates are present does `completion` fill. Check which one you have
before reading either.
