---
name: head-skip-tail
version: 0.0.1
auth: zef:lizmat
kind: Distribution · compatibility
summary: Sub forms of `head`, `skip` and `tail` for compilers that lack
  them — a no-op on Rakudo, and load-bearing on Raku++.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/head-skip-tail
source: https://github.com/lizmat/head-skip-tail.git
---

## What it is for

`@list.head(4)` is a method; `head(4, @list)` as a sub is convenient when you
are writing point-free code or feeding a `==>` chain. Recent Rakudos have the
subs in core. This distribution supplies them where they are missing, and
stands down where they are not.

The guard is a conditional `sub EXPORT`: if `&head` is already in `CORE::`,
the export map is empty and `use head-skip-tail` does nothing at all.

## The three subs

```raku name="basics"
use head-skip-tail;

my @a = ^10;
say 'head   4 : ', head(4, @a);
say 'head *-4 : ', head(*-4, @a);
say 'skip   4 : ', skip(4, @a);
say 'skip *-4 : ', skip(*-4, @a);
say 'tail   4 : ', tail(4, @a);
say 'tail *-4 : ', tail(*-4, @a);
say '';
say 'each is a proto (Mu, |) with one multi ($n, +values) that delegates';
say 'to the matching method on the list.';
```

```output
head   4 : (0 1 2 3)
head *-4 : (0 1 2 3 4 5)
skip   4 : (4 5 6 7 8 9)
skip *-4 : (6 7 8 9)
tail   4 : (6 7 8 9)
tail *-4 : (4 5 6 7 8 9)

each is a proto (Mu, |) with one multi ($n, +values) that delegates
to the matching method on the list.
```

## The argument shapes

```raku name="shapes"
use head-skip-tail;

my @a = 1, 2, 3, 4, 5;
my @b = 10, 20;

say 'the +values slurpy uses the ONE-ARG rule, so two arrays stay two:';
say '  head(2, @a, @b) = ', head(2, @a, @b).raku;
say '  head(2, 7, 8, 9) = ', head(2, 7, 8, 9).raku;
say '';
say 'every result is a Seq:';
say '  ', head(2, @a).WHAT.^name;
say '';
say 'degenerate counts do not complain:';
for 0, -1, 99 -> $n {
    say sprintf('  head(%3d, @a) = %s   skip(%3d, @a) = %s',
                $n, head($n, @a).raku, $n, skip($n, @a).raku);
}
say '';
say 'and head() with no list at all is an empty Seq, not an error:';
say '  head(2) = ', head(2).raku;
say '';
say 'a lazy source is where the two engines part — a +@ slurpy is always';
say 'eager on Raku++, and an infinite .map collapses to nothing there.';
say 'Take the head with the METHOD when the source is lazy:';
say '  (1..Inf).map(* * 2).head(3) = ', (1..Inf).map(* * 2).head(3).raku;
```

```output
the +values slurpy uses the ONE-ARG rule, so two arrays stay two:
  head(2, @a, @b) = ([1, 2, 3, 4, 5], [10, 20]).Seq
  head(2, 7, 8, 9) = (7, 8).Seq

every result is a Seq:
  Seq

degenerate counts do not complain:
  head(  0, @a) = ().Seq   skip(  0, @a) = (1, 2, 3, 4, 5).Seq
  head( -1, @a) = ().Seq   skip( -1, @a) = (1, 2, 3, 4, 5).Seq
  head( 99, @a) = (1, 2, 3, 4, 5).Seq   skip( 99, @a) = ().Seq

and head() with no list at all is an empty Seq, not an error:
  head(2) = ().Seq

a lazy source is where the two engines part — a +@ slurpy is always
eager on Raku++, and an infinite .map collapses to nothing there.
Take the head with the METHOD when the source is lazy:
  (1..Inf).map(* * 2).head(3) = (2, 4, 6).Seq
```

## The one thing to know

Dropping the `use` is not harmless on Raku++: bare `skip` resolves to
`Test`'s `skip`, which emits TAP output and returns `True`.

```raku name="collision"
use head-skip-tail;

my @a = ^10;
say 'with the use in place, all three are the iterable ones:';
say '  head(4, @a) = ', head(4, @a);
say '  skip(8, @a) = ', skip(8, @a);
say '  tail(2, @a) = ', tail(2, @a);
say '';
say 'without it, on Raku++, `skip` is Test::skip — it prints ten "ok"';
say 'lines to stdout and returns Bool::True. head and tail still resolve';
say 'to the setting`s own subs there, so only skip is affected, which is';
say 'exactly the kind of thing that survives a quick test.';
say '';
say 'Test`s routines are visible without `use Test` on Raku++ at all —';
say 'ok, plan, is, todo and done-testing are all callable in a bare';
say 'script there and undeclared on Rakudo.';
```

```output
with the use in place, all three are the iterable ones:
  head(4, @a) = (0 1 2 3)
  skip(8, @a) = (8 9)
  tail(2, @a) = (8 9)

without it, on Raku++, `skip` is Test::skip — it prints ten "ok"
lines to stdout and returns Bool::True. head and tail still resolve
to the setting`s own subs there, so only skip is affected, which is
exactly the kind of thing that survives a quick test.

Test`s routines are visible without `use Test` on Raku++ at all —
ok, plan, is, todo and done-testing are all callable in a bare
script there and undeclared on Rakudo.
```

## Where the two engines differ

The guard itself. `CORE::.EXISTS-KEY('&head')` is `True` on Rakudo and `False`
on Raku++ — the `CORE::` stash does not expose setting-level subs there — so
the module stands down on one engine and installs all three on the other.

```raku name="guard"
use head-skip-tail;

say 'on Rakudo the guard fires and `use head-skip-tail` is a complete';
say 'no-op; the subs you call are the core ones.';
say '';
say 'on Raku++ the guard misfires and the module installs its own, which';
say 'is the reason the collision above matters there and not on Rakudo.';
say '';
say 'either way the ANSWERS are identical — the example output on this';
say 'page is byte-for-byte the same on both engines. Only which routine';
say 'you are calling differs:';
my @a = ^10;
say '  head(3, @a) = ', head(3, @a);
say '  skip(7, @a) = ', skip(7, @a);
say '  tail(3, @a) = ', tail(3, @a);
say '';
say 'so: keep the `use`. It costs nothing where the core has the subs and';
say 'it is the only thing standing between you and Test::skip where it';
say 'does not.';
```

```output
on Rakudo the guard fires and `use head-skip-tail` is a complete
no-op; the subs you call are the core ones.

on Raku++ the guard misfires and the module installs its own, which
is the reason the collision above matters there and not on Rakudo.

either way the ANSWERS are identical — the example output on this
page is byte-for-byte the same on both engines. Only which routine
you are calling differs:
  head(3, @a) = (0 1 2)
  skip(7, @a) = (7 8 9)
  tail(3, @a) = (7 8 9)

so: keep the `use`. It costs nothing where the core has the subs and
it is the only thing standing between you and Test::skip where it
does not.
```

One other engine difference worth not reading too much into: the `sub EXPORT`
exports do **not** leak through a transitive `use` on Raku++, unlike
`is export` ones — so a module that loads `head-skip-tail` does not pass the
subs on to its own importers. That is the correct behaviour, and Rakudo agrees
because it exports nothing in the first place.
