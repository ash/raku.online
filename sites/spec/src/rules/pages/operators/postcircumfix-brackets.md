---
title: Positional subscript
sym: "[ ]"
cat: postcircumfix
order: 10
status: written
summary: Indexing and slicing by position — one operator that returns an element, a list, or the whole thing depending on what you put inside it.
---

`@a[…]` looks up by position. What comes back depends entirely on the shape of what
is inside the brackets, and the bracket contents are ordinary Raku code evaluated in
list context — not a special index syntax.

This is `postcircumfix:<[ ]>`, distinct from [`circumfix:<[ ]>`](/rules/operators/circumfix-brackets/),
which *builds* an array. The difference is whether a term precedes the bracket.

## Rules

### One index returns one element

```raku
my @a = 10, 20, 30;
say @a[1];
```
```output
20
```

### More than one index returns a list — a slice

The result is a `List`, in the order you asked for, repeats included. It is not a
copy of a range of the array; it is the elements you named.

```raku
my @a = 10, 20, 30;
say @a[0, 2];
say @a[1, 1, 0];
```
```output
(10 30)
(20 20 10)
```

### The subscript is evaluated in list context, so anything list-like indexes

A range, a sequence, a `^n`, the result of a method call — all of them flatten into
the index list. There is no separate "slice syntax"; there is only list context.

```raku
my @a = 1 .. 10;
say @a[2 .. 4];
say @a[^3];
say @a[(1, 2).map(* * 2)];
```
```output
(3 4 5)
(1 2 3)
(3 5)
```

### `*` inside a subscript means "the number of elements"

`*-1` is not a negative index — it is a `WhateverCode` closure that the subscript
calls with the element count. That is why it composes with arithmetic.

```raku
my @a = 10, 20, 30;
say @a[*-1];
say @a[*-1, *-2];
```
```output
30
(30 20)
```

### An empty subscript is the whole thing — the zen slice

`@a[]` returns the container itself, not a copy and not a flattened list. It is how
you ask for "everything" without changing the shape.

```raku
my @a = 10, 20, 30;
say @a[];
```
```output
[10 20 30]
```

### Reading past the end returns `Any` and does not grow the array

```raku
my @a;
say @a[3].WHAT;
say @a.elems;
```
```output
(Any)
0
```

### Assigning past the end *does* grow the array, filling with `Any`

The asymmetry is deliberate: reading is free, writing commits.

```raku
my @a;
@a[3] = 1;
say @a.raku;
```
```output
[Any, Any, Any, 1]
```

### A slice is assignable

```raku
my @a = 1, 2, 3;
@a[0, 1] = 9, 8;
say @a;
```
```output
[9 8 3]
```

### Adverbs select what the subscript returns

The subscript takes adverbs that change the result from the value to something about
the value: `:exists`, `:delete`, `:k` (keys), `:v` (values), `:p` (pairs).

```raku
my @a = <a b c>;
say @a[2]:exists;
say @a[9]:exists;
say @a[0, 1]:kv;
```
```output
True
False
(0 a 1 b)
```

`:delete` returns what was there and leaves a hole, not a shorter array:

```raku
my @a = <a b c>;
say @a[1]:delete;
say @a.raku;
```
```output
b
["a", Any, "c"]
```

### Booleans index, because `Bool` is an `Int`

`True` is `1` and `False` is `0`, so a boolean subscript is a perfectly ordinary
numeric one. Occasionally useful, more often a bug.

```raku
my @a = 10, 20, 30;
say @a[True, False];
```
```output
(20 10)
```

### Subscripting a scalar item yields the item itself at index 0

Any value is a one-element list when asked. This is why `%h[0]` gives you the hash
rather than an error, and why `$s[0]` is the whole string rather than its first
character.

```raku
my $s = "abc";
say $s[0];
my %h = a => 1;
say %h[0];
```
```output
abc
{a => 1}
```

For a character, index the `.comb` list — `$s.comb[0]` — or use `.substr(0, 1)`.

## Traps

### Negative indices are not "from the end"

`@a[-1]` is an error, not the last element. Raku spells that `@a[*-1]`. Rakudo
rejects it at compile time with a message pointing you at `*-1`; Raku++ accepts the
parse and throws `X::OutOfRange` when the subscript runs. Either way the code is
wrong — but the two implementations tell you at different moments.

```bad
my @a = 1, 2, 3;
say @a[-1];
```

### A single list subscript flattens; a list *inside* the subscript does not

One list in the brackets is just an index list:

```raku
my @a = 10, 20, 30;
say @a[(0, 1)];
```
```output
(10 20)
```

But a list nested among other indices is a different matter, and this is where the
two implementations part company. Rakudo mirrors the shape of the subscript into the
result, so `@a[0, (1, 2)]` returns a two-element list whose second element is itself
a list:

```diverge
my @a = 10, 20, 30;
say @a[0, (1, 2)];
```
```text
Rakudo:  (10 (20 30))
Raku++:  (10 20 30)
```

Raku++ flattens. If the shape matters, do not rely on the subscript to preserve it —
build it explicitly. To index into a *nested array*, chain the subscripts
(`@a[0][1]`) or use the semicolon form below.

### `;` inside a subscript is the multi-dimensional form, and Raku++ differs on flat arrays

`@a[0;1]` indexes dimension by dimension. On a genuinely nested array both
implementations agree:

```raku
my @a = [1, 2], [3, 4];
say @a[0; 1];
```
```output
2
```

On a *flat* array, Rakudo lets a trailing dimension degenerate — `@a[1;0]` gives
`@a[1]` — while Raku++ returns `Any`. Treat `;` on a one-dimensional array as
undefined territory rather than relying on either answer.

```diverge
my @a = 1, 2, 3;
say @a[1; 0];
```

### Binding a slice: the same type with different rights

`my @b := @a[0, 1]` binds a `List` in both implementations — but not the same
kind of `List`. Rakudo's slice holds `@a`'s own containers: assigning to an
element of `@b` writes through into `@a`, while growing the list is refused.
Raku++ hands back a detached immutable `List`: assigning to an element is
refused — and `.push`, inconsistently, is allowed. Assign (`=`) instead of
bind (`:=`) unless you specifically need the binding.

```diverge
my @a = 1, 2, 3;
my @b := @a[0, 1];
@b[0] = 9;
say @a;
```
```text
Rakudo:  [9 2 3] — the slice elements are @a's own containers
Raku++:  Cannot modify an immutable List ((1 2))
```

```diverge
my @a = 1, 2, 3;
my @b := @a[0, 1];
@b.push(9);
say @b;
```
```text
Rakudo:  Cannot call 'push' on an immutable 'List'
Raku++:  (1 2 9)
```

## See also

- [`circumfix:<[ ]>`](/rules/operators/circumfix-brackets/) — the same brackets with no preceding term: an array composer
- [`postcircumfix:<{ }>`](/rules/operators/postcircumfix-braces/) — the associative subscript
- [`prefix:<[>`](/rules/operators/prefix-lbrack/) — the reduction metaoperator, `[+] @a`
