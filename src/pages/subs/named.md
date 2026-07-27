---
title: Named parameters & arguments
slug: named
status: full
order: 30
summary: Pass arguments by name with :$x parameters and the :$var / key => value forms.
---

A parameter written `:$name` is **named**, not positional: the caller supplies it by
name, in any order. Named arguments make call sites self-documenting, especially
when there are several.

## Declaring and passing named parameters

```raku
sub area(:$w, :$h) {
    $w * $h;
}
say area(w => 3, h => 4);
```
```output
12
```

Order is irrelevant — `area(h => 4, w => 3)` gives the same result.

## The `:$var` shortcut

When you already have variables of the same name, `:$w` at the call site is short
for `w => $w`. This pairs neatly with `:$w` parameters.

```raku
sub area(:$w, :$h) {
    $w * $h;
}
my ($w, $h) = 3, 4;
say area(:$w, :$h);
```
```output
12
```

## Notes

- Named parameters are optional by default; add `!` to require one: `:$w!`.
- A named parameter can have a default like any other: `:$h = 1`.
- `:$w` (colon-pair shorthand), `w => $w`, and `:w($w)` are three spellings of the
  same argument; `:w` alone is `w => True`.
