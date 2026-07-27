---
title: Equivalence & identity — eqv / ===
slug: equivalence
status: full
order: 43
summary: Compare structure (eqv) or object identity (===), beyond value equality.
---

Beyond `==` (numeric) and `eq` (string), Raku has `eqv` for **structural**
equivalence and `===` for **identity**. They answer "are these the same shape?" and
"are these the same value?" rather than just "do they compare equal?".

## eqv — same type and structure

`eqv` is true when two values have the same type *and* the same contents, all the way
down — so two lists match only if their elements match in order.

```raku
say (1, 2, 3) eqv (1, 2, 3);
say [1, 2] eqv [1, 3];
```
```output
True
False
```

## === — value identity

`===` tests whether two things are the same value (immutables) or the very same
object (mutables).

```raku
say 5 === 5;
say "a" === "a";
```
```output
True
True
```

Two `5`s and two `"a"`s are the same immutable value, so `===` is `True`.

## Notes

- `==`/`eq` compare *values* after coercion (`1 == 1.0` is `True`); `eqv` requires the
  same type too (`1 eqv 1.0` is `False`).
- For containers, `===` compares object identity: two separately-built arrays with
  equal contents are `eqv` but not `===`.
- `=:=` is the third, rarest one — it tests whether two variables are bound to the
  *same container*, not just equal values.
