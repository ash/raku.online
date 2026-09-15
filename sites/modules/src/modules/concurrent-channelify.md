---
name: Concurrent::Channelify
version: 0.1.0
auth: github:gfldex
kind: Distribution · concurrency
summary: Hand a list to a start block that pushes every element into a
  Channel, so a producing pipeline overlaps with a consuming one.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:gfldex/Concurrent::Channelify
source: git://github.com/gfldex/perl6-concurrent-channelify.git
---

## What it is for

A lazy list computed by one expensive step and consumed by another expensive
step runs both on the same thread, alternating. Putting a `Channel` between
them lets the producer run ahead on the thread pool while the consumer works,
which is free throughput if the two steps are genuinely independent.

This distribution is the thirty lines of plumbing that does that.

## Draining a list through a channel

```raku name="channelify"
use Concurrent::Channelify;

my @work = 1 .. 8;
my $c = channelify(@work);

say 'channelify returns : ', $c.^name;
say '  isa Channel      : ', $c ~~ Channel;
say '  .no-thread       : ', $c.no-thread;
say '';
my @got = $c.list;
say 'drained (sorted) : ', @got.sort.join(' ');
say 'count            : ', @got.elems;
say '';
say 'a second consumer sees an exhausted channel : ', $c.list.elems, ' items';
```

```output
channelify returns : Channel+{<anon|1>}
  isa Channel      : True
  .no-thread       : False

drained (sorted) : 1 2 3 4 5 6 7 8
count            : 8

a second consumer sees an exhausted channel : 0 items
```

The channel closes itself when the producer runs out, so `.list` terminates.

## The operator

```raku name="operator"
use Concurrent::Channelify;

say 'the module imports a sub and a postfix operator,';
say 'both bound to the same routine.';
say '';
my @a = 1 .. 5;
say 'the sub form : ', channelify(@a).list.sort.join(' ');
```

```output
the module imports a sub and a postfix operator,
both bound to the same routine.

the sub form : 1 2 3 4 5
```

The second name is a **postfix** spelled with the Unicode double arrow, and it
must be written tight against its operand, with no space before it. It
collides with Raku's core infix of the same spelling — the Unicode form of
`=>` — which is the thing to weigh before importing it, and which the two
engines handle differently; see the last section.

## What it accepts

```raku name="accepts"
use Concurrent::Channelify;

say 'an Array : ', channelify([1, 2, 3]).list.sort.join(' ');
say 'a List   : ', channelify((4, 5, 6)).list.sort.join(' ');
say '';
say ':no-thread runs the producer inline:';
my $n = channelify([1, 2, 3], :no-thread);
say '  .no-thread : ', $n.no-thread;
say '  contents   : ', $n.list.sort.join(' ');
say '';
for 42, 'text', %(a => 1) -> $bad {
    my $r = try channelify($bad);
    say sprintf('  %-6s -> %s', $bad.^name, $! ?? 'refused' !! 'accepted');
}
```

```output
an Array : 1 2 3
a List   : 4 5 6

:no-thread runs the producer inline:
  .no-thread : True
  contents   : 1 2 3

  Int    -> refused
  Str    -> refused
  Hash   -> refused
```

The parameter is `Positional:D`, so anything that is not a list is refused.

## The one thing to know

`channelify` returns a different **type** depending on an environment variable
read at import time.

The module's `EXPORT` sub checks `RAKUDO_MAX_THREADS` and, when it is 1,
silently substitutes a non-threaded implementation that returns a **`Seq`**
instead of a `Channel`. So `$r ~~ Channel` goes from `True` to `False`, and
every channel method — `.poll`, `.close`, `.receive`, `.send` — vanishes.

Code that drains with `.list` survives the switch. Anything that polls or
closes breaks on a machine that happens to have that variable set, at runtime,
with a method-not-found far from the `use` statement that decided it.

If you rely on the `Channel` interface, check `$c ~~ Channel` after
constructing, or do not use this.

## Where the two engines differ

On what importing the postfix does to the core infix. Under Raku++,
`use Concurrent::Channelify` **destroys** `infix:<⇒>` — `(1 ⇒ 2).raku` stops
parsing — while under Rakudo the two coexist and `1 ⇒ 2` still builds a
`Pair`. Either way the postfix must be written tight against its operand.

Raku++ also declines to bind a bare `Range` to the `Positional:D` parameter
even though `(1..5) ~~ Positional:D` is `True`, so `channelify(1..5)` works on
Rakudo and is refused on Raku++. Pass an `Array` or a `List`, as the examples
above do.

One thing that is the same on both and is the reason to think before using
this at all: the `Channel` is **unbounded**. There is no back-pressure, so a
producer racing ahead of a slow consumer allocates until you close the
channel. Feed it a lazy or infinite list and it will keep going. Closing does
stop it — the producer loop checks `$channel.closed` — so close it when you
stop consuming.
