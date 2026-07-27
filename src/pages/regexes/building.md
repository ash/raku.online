---
title: Quantifiers, anchors & alternation
slug: building
status: full
order: 40
summary: The building blocks — + * ? quantifiers, ^ $ anchors, and < a b > alternation.
---

Beyond literal text and metacharacters like `\d`, regexes are built from
quantifiers (how many), anchors (where), and alternation (which of several).

## Quantifiers and anchors

`+` means one-or-more, `*` zero-or-more, `?` zero-or-one. `^` and `$` anchor to the
start and end of the string, so `^ a+ $` means "nothing but `a`s".

```raku
say so "aaa" ~~ /^ a+ $/;
say so "" ~~ /^ a+ $/;
```
```output
True
False
```

`"aaa"` is all `a`s so it matches; the empty string fails because `+` needs at
least one.

## Alternation with `< … >`

A quoted word list `< cat dog >` matches any one of its alternatives — a concise
literal alternation.

```raku
for <cat dog fish> {
    say "$_: ", (/^ < cat dog > $/ ?? "pet" !! "other");
}
```
```output
cat: pet
dog: pet
fish: other
```

## Notes

- `< cat dog >` is the literal-alternation shortcut; for general alternation of
  sub-patterns use `||` (first match) or `|` (longest match).
- Character classes: `<[a..z]>` matches one lowercase letter, `<-[0..9]>` matches
  one non-digit — the `-` negates the class.
- Backslash classes `\d` `\w` `\s` (and their negations `\D` `\W` `\S`) are the
  common shortcuts for digit, word-char, and whitespace.
