---
title: given / when
slug: given-when
status: full
order: 30
summary: Topic dispatch — Raku's switch, matching with the smartmatch operator.
---

`given` sets the topic `$_`; `when` blocks test it with the smartmatch operator
`~~` and run the first match, then break out automatically. It is Raku's `switch`,
but far more general — `when` matches ranges, types, regexes, and more.

## Basic dispatch

```raku
given 5 {
    when 1..3 { say "low" }
    when 4..6 { say "mid" }
    default   { say "high" }
}
```
```output
mid
```

The `5` smartmatches against each `when` in turn; `4..6` matches, so `mid` prints
and the block exits without falling through.

## Matching types and values

Because `when` uses smartmatch, the target can be a type, a value, or a range —
whatever `~~` understands.

```raku
for 3, "hi", 4.5 {
    given $_ {
        when Int { say "$_ is an Int" }
        when Str { say "$_ is a Str" }
        default  { say "$_ is something else" }
    }
}
```
```output
3 is an Int
hi is a Str
4.5 is something else
```

## Notes

- `when` blocks break out by default; add `proceed` to fall through to the next
  one, or `succeed` to leave early.
- You can use `when` without `given` inside any block that sets `$_` (such as a
  `for` loop body).
- `given` is an expression: `my $label = do given $n { when * > 0 { "pos" } default { "non-pos" } }`.
