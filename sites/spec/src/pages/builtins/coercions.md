---
title: Coercions
slug: coercions
status: full
order: 70
summary: Convert between types with Int/Str/Num/Bool, the prefix + ~ ? operators, and .Type methods.
---

Raku converts between types explicitly. Each core type doubles as a coercer
(`Int(...)`), each has a prefix operator (`+` numeric, `~` string, `?` Boolean), and
each value has `.Int`/`.Str`/`.Num`/`.Bool` methods — three spellings of the same
conversions.

## Type-named coercers

```raku
say Int("42");
say Str(42);
say Num("3.5");
```
```output
42
42
3.5
```

## Prefix coercion operators

`+` forces numeric context, `~` string context, `?` Boolean context.

```raku
say +"3.5";
say ~42;
say ?0;
say ?5;
```
```output
3.5
42
False
True
```

`?0` is `False` and `?5` is `True` — the Boolean view of a number is its
truthiness (zero is false).

## Coercion methods

The `.Type` methods do the same conversions, and some carry extra arguments — `.base`
renders an integer in another radix.

```raku
say 3.14.Int;
say (1/2).Num;
say 255.base(16);
```
```output
3
0.5
FF
```

## Notes

- `.Int` on a fractional value **truncates** toward zero (`3.9.Int` is `3`), it does
  not round.
- Numeric coercion of a bad string is a soft failure (a `Failure`), not a crash —
  guard with `//` or check `.defined` when parsing untrusted input.
- The prefix operators are the idiomatic short forms: `+$x`, `~$x`, `?$x` read better
  than the method calls in expressions.
