---
name: Cache::Async
version: 0.3.4
auth: zef:lizmat
kind: Distribution · caching
summary: A thread-safe read-through cache built around a producer closure —
  every get returns a Promise, and concurrent requests for one key collapse
  onto a single producer call.
status: full
suite: 10 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/Cache::Async
source: https://github.com/lizmat/Cache-Async.git
---

## What it is for

A cache in front of a slow backend has one hard problem and it is not storage.
It is the stampede: when a popular key expires, every request that arrives in
the next few milliseconds sees a miss and calls the backend, and you have
turned one slow call into fifty.

This distribution solves that. Ask for a key and you always get a `Promise`;
if a producer is already running for that key, you get *its* promise rather
than starting a second one.

## Caching

```raku name="cache"
use Cache::Async;

my atomicint $calls = 0;
my $cache = Cache::Async.new(
    max-size => 10,
    producer => sub ($k, *@extra) {
        atomic-fetch-inc($calls);
        "value-for-$k" ~ (@extra ?? '+' ~ @extra.join(',') !! '')
    },
);

my $first = $cache.get('a');
say 'get returns a : ', $first.^name;
await $first;
say '';
say 'a       -> ', await $cache.get('a');
say 'a again -> ', await $cache.get('a');
say 'b       -> ', await $cache.get('b');
say 'extra arguments reach the producer : ', await $cache.get('c', 1, 2);
say '';
say 'producer calls : ', atomic-fetch($calls);
say 'hits, misses   : ', $cache.hits-misses.raku;
```

```output
get returns a : Promise

a       -> value-for-a
a again -> value-for-a
b       -> value-for-b
extra arguments reach the producer : value-for-c+1,2

producer calls : 3
hits, misses   : (2, 3)
```

Every `get` must be awaited before the next if you want reproducible counts —
the whole point is that they can overlap.

## The rest of the interface

```raku name="interface"
use Cache::Async;

my $cache = Cache::Async.new(producer => sub ($k) { $k.uc });

await $cache.get('a');
say 'get-if-present("a")    : ', $cache.get-if-present('a').raku;
say 'get-if-present("nope") : ', $cache.get-if-present('nope').raku;
say '';
$cache.put('warm', 'preloaded');
say 'put then get-if-present : ', $cache.get-if-present('warm').raku;
$cache.remove('a');
say 'after remove("a")       : ', $cache.get-if-present('a').raku;
$cache.clear;
say 'after clear             : ', $cache.get-if-present('warm').raku;
say '';
say 'defaults : max-size=', $cache.max-size,
    ' cache-undefined=', $cache.cache-undefined,
    ' max-age=', $cache.max-age.raku;
```

```output
get-if-present("a")    : "A"
get-if-present("nope") : Nil

put then get-if-present : "preloaded"
after remove("a")       : Nil
after clear             : Nil

defaults : max-size=1024 cache-undefined=True max-age=Any
```

`get-if-present` does not call the producer and does not touch the counters.

## Ages and validation

```raku name="ages"
use Cache::Async;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-34s %s', $label, $! ?? $!.message !! 'accepted');
}

attempt 'max-age < refresh-after', {
    Cache::Async.new(producer => sub ($k) { $k },
        max-age => Duration.new(1), refresh-after => Duration.new(5))
};
attempt 'jitter with no age set', {
    Cache::Async.new(producer => sub ($k) { $k }, jitter => Duration.new(1))
};
attempt 'jitter >= max-age', {
    Cache::Async.new(producer => sub ($k) { $k },
        max-age => Duration.new(1), jitter => Duration.new(2))
};
attempt 'a consistent set', {
    Cache::Async.new(producer => sub ($k) { $k },
        max-age => Duration.new(10), refresh-after => Duration.new(5),
        jitter => Duration.new(1))
};
```

```output
max-age < refresh-after            max-age cannot be less than refresh-after
jitter with no age set             jitter set, but neither max-age nor refresh-after set
jitter >= max-age                  jitter cannot be larger or equals to refresh-after/max-age
a consistent set                   accepted
```

The three consistency rules all fire with messages that say what is wrong,
which is better than most constructors manage.

## The one thing to know

A producer failure is cached **permanently**. There is no negative time to
live and no retry.

```raku name="poison-trap"
use Cache::Async;

my atomicint $calls = 0;
my $cache = Cache::Async.new(producer => sub ($k) {
    my $n = atomic-inc-fetch($calls);
    die 'transient outage' if $n == 1;      # fails once, then works
    "value-$n"
});

for 1 .. 4 -> $i {
    my $p = $cache.get('k');
    await Promise.anyof($p, Promise.in(5));
    say "attempt $i : ", $p.status;
}
say 'producer was called ', atomic-fetch($calls), ' time(s) in four attempts';
say '';
$cache.remove('k');
my $p = $cache.get('k');
await Promise.anyof($p, Promise.in(5));
say 'after remove("k"), the next get : ', $p.status,
    ' -> ', $p.status ~~ Kept ?? $p.result !! 'still broken';
```

```output
attempt 1 : Broken
attempt 2 : Broken
attempt 3 : Broken
attempt 4 : Broken
producer was called 1 time(s) in four attempts

after remove("k"), the next get : Kept -> value-2
```

One call, four attempts. Every later `get` hands back the same broken
`Promise`; `max-age` does not help, because the entry's promise is still
defined and the value path is never reached; and `get-if-present` reports
`Nil`, so nothing in the interface even tells you the key is stuck.

A transient backend blip therefore becomes a permanent hole for the lifetime
of the process. Catch inside the producer and return a sentinel, or `remove`
the key when you see a broken promise.

## Where the two engines differ

On a cache built with no producer at all. Rakudo refuses it —
`Impossible coercion from 'Str' into 'Callable'` — while Raku++ calls the
undefined `Callable` and gets its first argument back, turning the cache into
a silent identity function. Supply a producer and the engines agree
everywhere.

Three things that are not engine differences and are worth knowing before you
rely on them.

**`hits-misses` is a reader-clears gauge, not a counter.** It reports the
counts since the last call and resets them, so two monitoring callers each see
part of the traffic and neither sees the total.

**The eviction is FIFO, not LRU.** The hit path does not move an entry to the
front — the source carries the author's own note wondering whether it should —
so a key read five times is evicted before a key read once, if it was inserted
first.

**`put` past `max-size` throws from inside the module**, because it inserts
into the entry hash without linking the entry into the recency list. Warming a
cache with `put` is safe only below `max-size`; `get` past it is fine.
