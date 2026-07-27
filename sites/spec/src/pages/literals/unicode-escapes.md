---
title: Unicode escapes
slug: unicode-escapes
status: full
order: 35
summary: Write any character by codepoint (\x[…]) or by its Unicode name (\c[…]).
---

Inside a double-quoted string you can name any character two ways: `\x[…]` by
hexadecimal codepoint, and `\c[…]` by its official Unicode name. Both produce the
actual character.

## By codepoint — `\x[…]`

```raku
say "\x[41]\x[42]";
say "\x[3B1]";
```
```output
AB
α
```

`\x[41]` is `A` (U+0041); `\x[3B1]` is `α` (U+03B1).

## By name — `\c[…]`

`\c[NAME]` inserts the character with that Unicode name — self-documenting for
characters you can't easily type.

```raku
say "\c[LATIN SMALL LETTER E WITH ACUTE]";
```
```output
é
```

## Notes

- `\x[…]` takes hex; the older `\x41` (no brackets) works for short codes too, and
  `\o[…]` takes octal.
- `\c[…]` also accepts a control-character name (`\c[TAB]`) and multiple
  comma-separated names in one escape.
- The `uniname` method is the inverse — it gives a character's Unicode name; see
  [Unicode & graphemes](/methods/unicode/).
