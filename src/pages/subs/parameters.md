---
title: Parameters — optional, default & slurpy
slug: parameters
status: full
order: 20
summary: Required and optional positionals, default values, and slurpy *@ / *% catch-alls.
---

A signature's positional parameters are required by default. A `?` makes one
optional, an `= value` gives it a default, and a `*` makes it **slurpy** —
absorbing all remaining arguments.

## Default values

A parameter with `= expr` uses that value when the argument is omitted.

```raku
sub g($x, $y = 10) {
    $x + $y;
}
say g(5);
say g(5, 1);
```
```output
15
6
```

## Optional parameters

A trailing `?` marks a parameter optional; when absent it is undefined, which
`.defined` detects.

```raku
sub h($x, $y?) {
    $y.defined ?? "$x,$y" !! "$x only";
}
say h(1);
say h(1, 2);
```
```output
1 only
1,2
```

## Slurpy parameters

A `*@array` parameter collects all remaining positional arguments into a list;
`*%hash` does the same for named ones.

```raku
sub total(*@nums) {
    [+] @nums;
}
say total(1, 2, 3, 4);
```
```output
10
```

## Notes

- Order matters: required positionals come first, then optional/defaulted ones,
  then the slurpy — which must be last among positionals.
- A defaulted parameter is implicitly optional; you rarely need both `?` and `=`.
- The default expression can reference earlier parameters: `sub f($x, $y = $x) {…}`.
