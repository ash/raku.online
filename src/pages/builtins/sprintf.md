---
title: sprintf & fmt — formatting
slug: sprintf
status: full
order: 80
summary: printf-style formatting of numbers and strings with %-directives.
---

`sprintf` builds a string from a format template and arguments, using the familiar
`%`-directives. The `.fmt` method is the same formatting applied to a single value.

## Numbers, precision, padding

`%d` is an integer, `%.2f` a fixed-point float, `%05d` zero-pads to width 5.

```raku
say sprintf("%d apples", 5);
say sprintf("%.2f", pi);
say sprintf("%05d", 42);
```
```output
5 apples
3.14
00042
```

## Radix directives

`%x`, `%o`, `%b` render an integer in hex, octal, and binary.

```raku
say sprintf("%x", 255);
say sprintf("%b", 10);
say sprintf("%o", 64);
```
```output
ff
1010
100
```

## String alignment

`%-6s` left-justifies in a field of width 6; `%6s` right-justifies.

```raku
say sprintf("%-6s|", "hi");
say sprintf("%6s|", "hi");
```
```output
hi    |
    hi|
```

## The .fmt method

`.fmt` formats a single value with one directive — handy in a `map` or interpolation.

```raku
say 255.fmt("%04x");
say 42.fmt("%+d");
```
```output
00ff
+42
```

## Notes

- `printf` is `sprintf` that writes straight to standard output instead of returning
  the string.
- `.fmt` on a list formats each element and joins them; a second argument sets the
  separator: `(1,2,3).fmt("%02d", "-")` gives `01-02-03`.
- Directives follow C's `printf` family, so width, precision, and flags (`-`, `+`,
  `0`, space) combine as usual.
