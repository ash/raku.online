---
title: Native types — int / num / str
slug: native
status: divergent
order: 70
summary: Fixed-width machine types, with one Raku++ difference on native arrays.
---

Lowercase `int`, `num`, and `str` are **native** types — fixed-width machine values
without the object wrapper of `Int`/`Num`/`Str`. Native scalars behave the same in
Raku++ and Rakudo; native *arrays* differ in their type (see the divergence).

## Native scalars

A native scalar holds a machine value but introspects as its boxed type.

```raku
my int $x = 5;
say $x;
say $x.WHAT;
```
```output
5
(Int)
```

## Native arrays hold the values fine

```raku
my int @a = 1, 2, 3;
say @a;
```
```output
[1 2 3]
```

## Divergence: the native-array type

A `my int @a` is a genuinely unboxed `array[int]` in Rakudo, but Raku++ represents it
as the boxed `Array[int]`. The contents are identical; only the type object differs.

```raku
my int @a = 1, 2, 3;
say @a.WHAT;
```

| Expression | Rakudo (reference) | Raku++ |
| ---------- | ------------------ | ------ |
| `(my int @a).WHAT` | `(array[int])` | `(Array[int])` |

> Run the block to see Raku++'s result. This is a representation difference — the
> array works either way.

## Notes

- Native scalars are for performance and interop; you rarely need them in ordinary
  code, where `Int`/`Num`/`Str` are the defaults.
- A native value can't hold a type object (there's no "undefined" machine int), so
  native variables default to `0`/`0e0`/`""` rather than an undefined value.
- The boxed types (`Int`, `Num`, `Str`) are what nearly every example elsewhere in
  this spec uses.
