---
title: Re-dispatch — callsame, nextsame & friends
slug: redispatch
status: full
order: 43
summary: From inside a routine, call the next matching candidate — a parent method or the next multi.
---

When several routines could handle a call — an overriding method and the parent it
shadows, or a chain of `multi` candidates — you often want to run *the next one down*
from inside the current one. The re-dispatch routines do exactly that: `callsame` and
`callwith` run the next candidate and **return its result to you**; `nextsame` and
`nextwith` **hand control off** to it and never come back. `same` reuses the current
arguments; `with` supplies new ones.

|            | reuse current args | give new args |
| ---------- | ------------------ | ------------- |
| **return here** | `callsame`   | `callwith`    |
| **tail-call**   | `nextsame`   | `nextwith`    |

## Extending a parent method

Inside an override, `callsame` runs the method it replaced — here the `Animal`
version — so a subclass can *add to* behaviour instead of copying it.

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

The chain follows the full inheritance order, so each level can wrap the one below:

```raku
class A { method m { "A" } }
class B is A { method m { callsame() ~ "B" } }
class C is B { method m { callsame() ~ "C" } }
say C.m;
```
```output
ABC
```

## Deferring to the next multi

Among `multi` candidates, `callsame` runs the next-most-specific one. Here the `Int`
candidate decorates the result of the generic `Any` candidate.

```raku
multi describe(Int $n) { "number: " ~ callsame() }
multi describe(Any $x) { "value $x" }
say describe(5);
```
```output
number: value 5
```

## return vs. tail-call

The `call*` forms return the next candidate's result so you can keep working with it;
the `next*` forms transfer control, so any code after them never runs.

```raku
multi f(Int $x) { my $r = callsame; "[$r]" }   # returns, then wraps
multi g(Int $x) { nextsame; "NEVER" }          # hands off, this line is dead
multi f(Any $x) { "base" }
multi g(Any $x) { "base" }
say f(3);
say g(3);
```
```output
[base]
base
```

## Passing different arguments

`callwith`/`nextwith` re-dispatch with a fresh argument list — and `samewith`
restarts the *whole* dispatch from the top with new arguments, the idiomatic way to
recurse across multis.

```raku
multi fac(0)      { 1 }
multi fac(Int $n) { $n * samewith($n - 1) }
say fac(5);
```
```output
120
```

## Notes

- `callsame`/`nextsame` take no arguments (they reuse the current `@_`); `callwith`/
  `nextwith` take the new argument list.
- These work in method overrides ([Inheritance](/types/inheritance/)) and in
  `multi` chains ([Multi dispatch](/subs/multi/)) alike — same routines, same
  rules.
- `samewith` differs from `callwith`: `callwith` runs the *next* candidate, while
  `samewith` re-runs dispatch from scratch — so it can land back on the current
  candidate, which is what makes recursive multis terminate.
- A wrapped routine (`&r.wrap({ … callsame() … })`) uses the same mechanism: the wrapper
  calls `callsame` to invoke the original.
