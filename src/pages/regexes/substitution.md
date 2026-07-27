---
title: Substitution
slug: substitution
status: full
order: 30
summary: Replace matched text in place with s///, or every occurrence with s:g///.
---

`s/pattern/replacement/` finds the pattern and replaces it. Applied with `~~` to a
mutable variable, it edits that variable in place. By default it replaces the
**first** match; the `:g` adverb replaces them all.

## First match

```raku
my $s = "foo";
$s ~~ s/o/0/;
say $s;
```
```output
f0o
```

Only the first `o` is replaced, giving `f0o`.

## Global substitution

```raku
my $s = "foo";
$s ~~ s:g/o/0/;
say $s;
```
```output
f00
```

## Notes

- The target must be assignable — `$s ~~ s/…/…/` mutates `$s`. To get a *new*
  string without touching the original, use the `.subst` method:
  `"foo".subst("o", "0", :g)`.
- The replacement side is a double-quoted string context, so it can interpolate —
  including the match's own captures, e.g. `s/(\w+)/[$0]/`.
- Related adverbs: `:i` (case-insensitive), `:g` (global); they combine, e.g.
  `s:g:i/…/…/`.
