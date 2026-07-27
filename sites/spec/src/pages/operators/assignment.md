---
title: Assignment operators
slug: assignment
status: full
order: 85
summary: Plain = and the OP= family that combine an operation with assignment.
---

`=` assigns. For almost every infix operator there is a matching `OP=` form that
applies the operator to the current value and stores the result — `$x += 3` is
`$x = $x + 3`.

## Arithmetic assignment

```raku
my $x = 5;
$x += 3;
$x **= 2;
say $x;
```
```output
64
```

`5 + 3` is `8`, then `8 ** 2` is `64`.

## String assignment

`~=` appends (the assignment form of the `~` concatenation operator).

```raku
my $s = "a";
$s ~= "b";
say $s;
```
```output
ab
```

## Logical assignment

`//=`, `||=`, and `&&=` assign only when the current value is undefined / false /
true — the "set a default" idiom.

```raku
my $y;
$y //= 10;
say $y;
my $z = 0;
$z ||= 5;
say $z;
```
```output
10
5
```

## Notes

- The pattern is fully general: `~=`, `+=`, `-=`, `*=`, `/=`, `%=`, `**=`, `x=`,
  `min=`, `max=`, and more all exist.
- `.=` is method-assign: `$obj .= method` is `$obj = $obj.method`, e.g.
  `$str .= uc`. (On an `@array`, `@a .= reverse` reassigns it; Raku++ gists the
  result as `(…)` where Rakudo keeps `[…]` — a display difference.)
- `//=` keys on definedness and `||=` on truth, mirroring the
  [logical operators](/operators/logical/).
