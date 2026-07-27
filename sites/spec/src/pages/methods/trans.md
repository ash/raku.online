---
title: Character translation — trans with ranges
slug: trans
status: full
order: 12
summary: Map whole ranges of characters at once — upcasing, rot13, and the like.
---

`.trans` translates characters by a mapping. Beyond single characters (see
[String methods](/methods/string/)), the two sides can be **ranges**, so a
whole alphabet maps in one go — the `tr///` of other languages, generalised.

## Range-to-range mapping

```raku
say "hello".trans("a..z" => "A..Z");
say "abc".trans("abc" => "xyz");
```
```output
HELLO
xyz
```

`"a..z" => "A..Z"` maps each lowercase letter to its uppercase counterpart by
position.

## rot13 in one call

Multiple ranges concatenate, so a single `.trans` can rotate both cases — the classic
rot13.

```raku
say "Hello".trans("a..zA..Z" => "n..za..mN..ZA..M");
```
```output
Uryyb
```

## Notes

- The from- and to-sides are matched position by position, so their lengths must
  correspond; a range on one side pairs with a range of equal size on the other.
- Pass a list of pairs to apply several independent mappings at once:
  `.trans(['a' => '1', 'b' => '2'])`.
- Unlike a regex substitution, `.trans` is a pure per-character map — fast and with no
  backtracking — ideal for transliteration.
