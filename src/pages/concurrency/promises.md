---
title: Promises, supplies & channels
slug: promises
status: full
browser: false
browser-why: needs OS threads
order: 10
summary: Raku's high-level concurrency — start/await, react/whenever, and Channels.
---

Raku++ implements Raku's high-level concurrency: `start` runs a block on another
thread and hands back a `Promise`, `await` waits for results, and `react`/`whenever`
consume asynchronous `Supply` streams. These run in the Raku++ interpreter and the
`--exe` native binary, matching Rakudo — but the in-browser playground is
single-threaded, so the examples here are shown with their verified output rather than
a Run button (see [Execution modes](/conformance/) for why).

## start and await

`start { … }` schedules the block on the thread pool and returns a `Promise`;
`await` blocks until it resolves and yields the value.

```raku
my $p = start { 40 + 2 };
say await $p;
```
```output
42
```

Several run concurrently; awaiting each collects its result.

```raku
my $a = start { 2 + 2 };
my $b = start { 3 * 3 };
say await($a) + await($b);
```
```output
13
```

## react / whenever

A `react` block sits and responds to events; each `whenever` subscribes to a
`Supply` and runs its body per emitted value.

```raku
react {
    whenever Supply.from-list(10, 20, 30) -> $v {
        say $v;
    }
}
```
```output
10
20
30
```

## Waiting on many promises

`Promise.allof` completes once every promise in a list has — then each `.result`
is ready.

```raku
my @p = (1..3).map(-> $n { start { $n * 10 } });
await Promise.allof(@p);
say @p.map(*.result);
```
```output
(10 20 30)
```

## Producing a Promise — vow

`start` gives you a Promise that some code fulfils. To create and fulfil one *by
hand*, take its **vow** (the private write-capability) and `.keep` it with a value —
or `.break` it with a failure.

```raku
my $p = Promise.new;
my $v = $p.vow;
$v.keep(42);
say await $p;
```
```output
42
```

`.break` moves the Promise to the `Broken` status; awaiting a broken Promise
rethrows.

```raku
my $p = Promise.new;
$p.vow.break("nope");
say $p.status;
```
```output
Broken
```

## Guarding shared state — Lock

When several threads touch the same data, a `Lock` serialises access: `.protect`
runs its block with the lock held, so updates don't interleave.

```raku
my $lock = Lock.new;
my @log;
await (^3).map(-> $i { start { $lock.protect({ @log.push($i) }) } });
say @log.sort;
```
```output
(0 1 2)
```

## Channels

A `Channel` is a thread-safe queue: one thread `.send`s, another reads. Closing it
ends the `.list`.

```raku
my $c = Channel.new;
start { $c.send($_) for 1..3; $c.close }
say $c.list.sort;
```
```output
(1 2 3)
```

## Notes

- The building blocks: `Promise` (`start`, `.then`, `await`, `Promise.allof`/`anyof`),
  `Supply`/`supply`/`emit`/`tap`, `Channel`, and `react`/`whenever`.
- These need real OS threads, which the browser WebAssembly sandbox doesn't provide —
  that's why they're documented here rather than run live.
- Run them with the interpreter (`rakupp program.raku`) or compile a native binary
  (`rakupp --exe program.raku`); both support threads.
