---
name: Hash::Ordered
version: 0.0.9
auth: zef:lizmat
kind: Distribution · data
summary: A hash whose keys come back in the order they were first assigned,
  through the ordinary hash syntax — a container trait rather than a new
  type to learn.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: Hash::Agnostic
raku-land: https://raku.land/zef:lizmat/Hash::Ordered
source: https://github.com/lizmat/Hash-Ordered
---

## What it is for

A hash has no order, and most of the time that is fine. It stops being fine
when the hash is going to be printed, serialised, diffed or shown to a
person: a configuration written back out with its sections shuffled, a JSON
payload whose keys move between runs, a table whose columns reorder
themselves. The usual workarounds are to sort the keys, which imposes an
order nobody asked for, or to keep a separate list of them, which the code
then has to maintain by hand.

This distribution keeps the list for you. It is a role applied as a
container trait, so the variable is still used with `%`, `{ }`, `.keys` and
everything else a hash does — only the order is now the order you built it
in.

## Insertion order, through the ordinary syntax

```raku name="order"
use Hash::Ordered;

my %config is Hash::Ordered;
%config<name>    = 'demo';
%config<port>    = 8080;
%config<verbose> = True;
%config<retries> = 3;

say %config.keys.join(',');
say %config.pairs.map({ .key ~ '=' ~ .value }).join(' ');
say %config<port>;
say %config.elems;

%config<name> = 'renamed';
say %config.keys.join(',');

%config<port>:delete;
say %config.keys.join(',');
%config<port> = 9090;
say %config.keys.join(',');
```

```output
name,port,verbose,retries
name=demo port=8080 verbose=True retries=3
8080
4
name,port,verbose,retries
name,verbose,retries
name,verbose,retries,port
```

Overwriting a key leaves it where it was; deleting one and putting it back
sends it to the end, which is the only sensible reading of "the order they
were first assigned" and still worth knowing, because
`%h<k> = %h<k>:delete` is therefore not a no-op.

Copying one into another needs the trait on the receiving declaration too,
and with it the order survives:

```raku name="copying"
use Hash::Ordered;

my %source is Hash::Ordered;
%source{$_} = $_.uc for <zebra apple mango>;

my %kept is Hash::Ordered = %source;
say %kept.keys.join(',');

my %plain = %source;
say %plain.^name;
say %source.keys.join(',');
```

```output
zebra,apple,mango
Hash
zebra,apple,mango
```

Under the Raku++ 3.28.0 release that second example was impossible: the
assignment reached the role's `STORE` with the hash as a single value
rather than as its pairs, counted an odd number of elements and threw. The
engine flattens it now, and the exception class it wanted to report with is
constructible too.

## The one thing to know

The order lives in the **container**, not in the data, so it is lost the
moment the hash is assigned into an ordinary `%` variable — and under
Raku++ that loss is invisible. `my %plain = %source` above is a plain
`Hash`, and Raku++'s plain hashes happen to iterate in insertion order, so
the keys look right there and shuffle under Rakudo.

That makes it the kind of mistake that passes every test on one engine.
Put `is Hash::Ordered` on every declaration that has to keep the order,
including the temporary one in the middle of a pipeline, and treat a bare
`my %h = …` as an order-destroying operation.

Two smaller things. Keys are stored in a native string array, so a
non-string key is refused under Rakudo and quietly accepted under Raku++ —
stringify keys yourself if the code has to run on both. And deleting a key
renumbers every key after it, so clearing a large ordered hash one key at a
time from the front is quadratic; build a fresh one instead.
