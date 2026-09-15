---
name: Lazy::Static
version: 0.0.1
auth: samgwise
kind: Distribution · concurrency
summary: Wrap a block in a closure that runs it at most once, on first call,
  and hands every later caller — on any thread — the same value.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/samgwise/Lazy::Static
source: https://github.com/samgwise/Lazy-Static.git
---

## What it is for

`state $x = expensive()` computes once and remembers — until two threads reach
it at the same moment, at which point both may run `expensive()` and one
result is thrown away. If `expensive()` opens a connection or allocates a
handle, throwing one away is not free.

This distribution is the thread-safe version. The first thread through runs
the generator; everyone else blocks on a `Promise` until the value is ready.

## Making something lazy

```raku name="lazy"
use Lazy::Static;

my $calls = 0;
my &answer = lazy-static -> { $calls++; 6 * 7 };

say 'generator calls before first use : ', $calls;
say 'call 1 -> ', answer();
say 'call 2 -> ', answer();
say 'call 3 -> ', answer();
say 'generator calls after three uses : ', $calls;
```

```output
generator calls before first use : 0
call 1 -> 42
call 2 -> 42
call 3 -> 42
generator calls after three uses : 1
```

`lazy-static` returns a zero-argument `Callable`. If you never call it, the
generator never runs.

## Under contention

```raku name="threads"
use Lazy::Static;

my atomicint $calls = 0;
my &value = lazy-static -> { atomic-fetch-inc($calls); sleep 0.2; 'computed-once' };

my @results = await (^16).map: { start value() };

say 'sixteen concurrent callers';
say '  distinct results : ', @results.unique.sort.join(',');
say '  result count     : ', @results.elems;
say '  generator calls  : ', $calls;
```

```output
sixteen concurrent callers
  distinct results : computed-once
  result count     : 16
  generator calls  : 1
```

Sixteen threads, one generator call. That is the whole point of the
distribution, and it holds.

## The one thing to know

A generator that dies wedges the closure forever. Not a retry, not a re-raise
— a permanent block.

```raku name="failure-trap"
use Lazy::Static;

my &value = lazy-static -> { die 'generator failed' };

my $first = (try value()) // "call 1 threw: {$!.message}";
say $first;

my $p = start { value() };
await Promise.anyof($p, Promise.in(3));
say 'call 2 status after three seconds: ', $p.status;
exit 0;
```

```output
call 1 threw: generator failed
call 2 status after three seconds: Planned
```

`Planned` is the proof. The guard counter is incremented *before* the
generator runs and the `Promise` is only kept on success, so the first caller
gets the exception and every later caller waits on a promise that will never
be kept. A generator that can fail — one that opens a file, reads a
configuration, touches a socket — will deadlock every subsequent consumer, and
in a thread pool that means the pool drains silently.

The `exit 0` above is load-bearing: without it the wedged thread keeps the
program from finishing. Wrap the generator body in your own `try` and return a
sentinel if it can fail.

## Where the two engines differ

Nowhere. All three spikes, including the deadlock, behaved identically on
Raku++ and Rakudo.

Two things about the distribution itself. It is **not in the zef index** — the
installer resolves it from the REA archive, and notes that the index path
carries no checksum, so transport security is the only integrity check. And
`rakupp test Lazy::Static` re-fetches over the network rather than testing the
installed copy, and reports no file count.
