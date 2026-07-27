---
title: for / while / until / loop
slug: loops
status: full
order: 20
summary: Iterate a list with for, condition-loop with while/until, C-style with loop.
---

Raku's loops cover three needs: walking a list (`for`), repeating while a condition
holds (`while`/`until`), and the explicit three-part C-style loop (`loop`).

## for — iterate a list

`for` binds each element to a signature variable. Use `->` to name it.

```raku
for 1..3 -> $i {
    say "i=$i";
}
say "sum ", [+] 1..10;
```
```output
i=1
i=2
i=3
sum 55
```

Take more than one at a time, or index with `.kv`:

```raku
for <a b c>.kv -> $i, $v {
    say "$i: $v";
}
```
```output
0: a
1: b
2: c
```

## while / until

`while` repeats as long as its condition is true; `until` is its negation.

```raku
my $i = 3;
while $i > 0 {
    say $i;
    $i--;
}
```
```output
3
2
1
```

## loop — the C-style form

`loop (init; test; step) { }` is the explicit three-part loop. A bare `loop { }`
with no parts runs forever (use `last` to break).

```raku
loop (my $j = 0; $j < 3; $j++) {
    say $j;
}
```
```output
0
1
2
```

## Notes

- Loop control: `last` breaks out, `next` skips to the next iteration, `redo`
  reruns the current one.
- `for` aliases read-write by default when you use `<-> $x`, so you can modify
  array elements in place.
- The postfix form `say $_ for 1..3` is the idiomatic one-liner for simple
  iteration.
