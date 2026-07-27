---
title: Regex adverbs — :i / :s / :g
slug: adverbs
status: full
order: 35
summary: Modify how a match works — case-insensitive, significant-space, global.
---

Adverbs tweak a match. Written after the `m`/`s`/`rx` (or on `~~`), they turn on
case-insensitivity (`:i`), significant whitespace (`:s`), global matching (`:g`), and
more.

## :i — case-insensitive

```raku
say so "HELLO" ~~ m:i/hello/;
say so "HELLO" ~~ /hello/;
```
```output
True
False
```

Without `:i`, the literal `hello` doesn't match `HELLO`.

## :s — significant space

By default whitespace in a regex is ignored. `:s` (sigspace) makes each space match
real whitespace (`\s+`), so patterns can be laid out with meaningful gaps.

```raku
say so "foo   bar" ~~ m:s/foo bar/;
```
```output
True
```

## :g — global

`:g` finds every match, returning a list of them.

```raku
say ("a1b2c3" ~~ m:g/\d/).elems;
```
```output
3
```

## Notes

- Adverbs stack: `m:i:g/…/` is both case-insensitive and global.
- `:g` on a substitution (`s:g/…/…/`) replaces every occurrence — see
  [Substitution](/regexes/substitution/).
- Other useful ones: `:r` (ratchet, no backtracking — the default for `token`),
  `:x(n)` (match exactly n times), `:nth(k)`.
