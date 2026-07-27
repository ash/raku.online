---
title: Lookahead & lookbehind assertions
slug: lookaround
status: full
order: 46
summary: Match a position based on what follows or precedes, without consuming it.
---

A lookaround checks the text *around* a position without including it in the match.
`<?before …>` succeeds when the following text matches; `<?after …>` looks at what
*precedes*. Each has a negated form (`<!before>` / `<!after>`). None consume
characters — they constrain a position.

## Positive lookahead — `<?before>`

```raku
say "foobar" ~~ /foo <?before bar>/;
say so "foobaz" ~~ /foo <?before bar>/;
```
```output
｢foo｣
False
```

The match is just `foo` (the lookahead adds no characters), and it only succeeds when
`bar` follows — so `foobaz` fails.

## Negative lookahead — `<!before>`

`<!before …>` matches only when the following text does **not** match.

```raku
say so "catfish" ~~ /cat <!before fish>/;
say so "catdog" ~~ /cat <!before fish>/;
```
```output
False
True
```

`cat` is rejected in `catfish` (fish follows) and accepted in `catdog`.

## Lookbehind — `<?after>` / `<!after>`

`<?after …>` is the mirror image: it constrains what comes *before* the position,
again without consuming it. This is the clean way to match a value only when it
follows a fixed prefix — capturing the value alone, not the prefix.

```raku
"cost: 42 USD" ~~ / <?after \: \s > (\d+) /;
say ~$0;
```
```output
42
```

The digits are captured, but the `: ` that had to precede them is not part of the
match. It works inside a substitution too — replace `bar` only when `foo` sits in
front of it:

```raku
say "foobar".subst(/ <?after foo> bar /, "BAZ");
```
```output
fooBAZ
```

`<!after …>` negates it — match only where the given text does **not** precede.

## Notes

- Because a lookaround consumes nothing, the overall match text excludes it — handy
  for "match X only in context Y" without capturing Y.
- Anchors like `^`, `$`, and word boundaries are themselves zero-width assertions —
  lookarounds generalise the idea to arbitrary patterns.
