---
title: Inheritance
slug: inheritance
status: full
order: 20
summary: Derive a class with `is`, and override methods in the subclass.
---

A class inherits from another with `is`. The subclass gains the parent's attributes
and methods, and may **override** any method by declaring one of the same name.

## Subclass and override

```raku
class Animal {
    method speak { "..." }
}
class Dog is Animal {
    method speak { "Woof" }
}
say Dog.new.speak;
```
```output
Woof
```

`Dog` inherits from `Animal` but replaces `speak`, so `Dog.new.speak` is `Woof`.

## Calling the overridden method

An override can still reach the method it replaced. `callsame` runs the next
candidate up the inheritance chain — the parent's version — so a subclass can *extend*
behaviour rather than discard it.

```raku
class Animal { method describe { "an animal" } }
class Dog is Animal {
    method describe { callsame() ~ " that barks" }
}
say Dog.new.describe;
```
```output
an animal that barks
```

## Notes

- `callsame` is one of a small family (`nextsame`, `callwith`, `nextwith`,
  `samewith`) for invoking the next candidate — see
  [Re-dispatch](/subs/redispatch/). You can also name the parent explicitly with
  `self.Animal::describe`.
- Raku supports multiple inheritance (`is A is B`), but composing **roles** is
  usually the better tool for sharing behaviour — see [Roles](/types/roles/).
- Every class ultimately inherits from `Mu` (via `Any`), which is where universal
  methods like `.WHAT` and `.defined` come from.
