---
name: JSON::Pretty::Sorted
version: 0.0.2
auth: github:holli-holzer
kind: Distribution · JSON
summary: A pretty-printing JSON writer with a caller-supplied ordering hook
  threaded through the whole document.
status: partial
suite: no test files, so trivially green
tested: 2026-09-15
license: GPL-3.0
depends: none beyond the core
raku-land: https://raku.land/github:holli-holzer/JSON::Pretty::Sorted
source: https://github.com/holli-holzer/raku-JSON-Pretty-Sorted.git
---

## What it is for

JSON written from a Raku `Hash` comes out in hash order, which is arbitrary
and, on some engines, different every run. That makes two things impossible:
diffing two generated documents, and committing one to version control without
spurious churn.

The fix is to impose an order. This distribution's premise is that the order
should be yours to choose, so it takes a sorter block and threads it through
every level.

## Writing JSON

```raku name="write"
use JSON::Pretty::Sorted;

my &bykey = { $^a.key cmp $^b.key };

my %data = zebra => 1, apple => 2, mango => 3, banana => 4;
say to-json(%data, sorter => &bykey);
```

```output
{
  "apple" : 2,
  "banana" : 4,
  "mango" : 3,
  "zebra" : 1
}
```

## Nested documents

```raku name="nested"
use JSON::Pretty::Sorted;

my &bykey = { $^a.key cmp $^b.key };

my %nest = zebra => 1, apple => { zz => 1, aa => 2 }, mango => 3;
say to-json(%nest, sorter => &bykey);
```

```output
{
  "apple" : {
    "aa" : 2,
    "zz" : 1
  },
  "mango" : 3,
  "zebra" : 1
}
```

The sorter reaches the inner hash too, which is the feature — a single block
orders the whole document.

## Reading back

```raku name="read"
use JSON::Pretty::Sorted;

my &safe = { ($^x ~~ Pair ?? $x.key !! $x) cmp ($^y ~~ Pair ?? $y.key !! $y) };
my $text = to-json({ b => 1, a => [1, 2] }, sorter => &safe);
my %back = from-json($text);
say 'round trip : ', %back.keys.sort.map({ "$_=" ~ %back{$_}.raku }).join(' ');
say '';
say 'scalars:';
say '  from-json("123")  : ', from-json('123').raku;
say '  from-json(\'"s"\')  : ', from-json('"s"').raku;
say '  from-json("true") : ', from-json('true').raku;
say '  from-json("null") : ', from-json('null').raku;
say '';
say 'malformed input throws : ', (try from-json('{')).defined ?? 'no' !! 'yes';
```

```output
round trip : a=$[1, 2] b=1

scalars:
  from-json("123")  : 123
  from-json('"s"')  : "s"
  from-json("true") : Bool::True
  from-json("null") : Any

malformed input throws : yes
```

## The one thing to know

Out of the box the module does not sort anything, and the obvious fix crashes
on any document containing an array.

```raku name="sorter-trap"
use JSON::Pretty::Sorted;

my %data = zebra => 1, apple => 2, mango => 3;
say 'with no sorter, the default is { 0 } — a constant key,';
say 'so .sort is stable and simply preserves hash order.';
say '';
say 'and a key sorter reaches ARRAY elements too:';
my $r = try to-json({ b => [3, 1, 2], a => 'x' }, sorter => { $^x.key cmp $^y.key });
say '  ', $! ?? 'threw ' ~ $!.^name !! 'worked';
say '';
say 'the sorter has to handle both Pairs and bare elements:';
my &safe = { ($^x ~~ Pair ?? $x.key !! $x) cmp ($^y ~~ Pair ?? $y.key !! $y) };
say to-json({ b => [3, 1, 2], a => 'x' }, sorter => &safe);
```

```output
with no sorter, the default is { 0 } — a constant key,
so .sort is stable and simply preserves hash order.

and a key sorter reaches ARRAY elements too:
  threw X::Method::NotFound

the sorter has to handle both Pairs and bare elements:
{
  "a" : "x",
  "b" : [
    1,
    2,
    3
  ]
}
```

The default is `:&sorter = {0}` — a block returning a constant — so `.sort`
compares every element as equal and the output comes back in whatever order
the hash iterated. The module's name promises sorting; a plain `to-json` gives
you none.

Then the natural fix, a key comparator, is passed down to the `Positional`
candidate and applied to **array elements**, which have no `.key`. On a
document with any array in it, the call dies.

And note what the working version above did to the array: it **reordered it**.
JSON array order is semantically significant, so a sorter that survives a
document may still corrupt it. Write a sorter that leaves non-`Pair` arguments
in place.

## Where the two engines differ

In hash iteration order, which is the whole problem the module exists to
solve. With no sorter, Raku++ emits keys in insertion order and Rakudo in a
per-process randomised order — both stable within one process, neither sorted,
and the two never agreeing.

That is why every example on this page passes an explicit sorter. With one,
the output is identical on both engines.

`:indent` shifts the closing brace as well as the contents, so the output is
not re-indentable by composition. And `from-json` throws
`JSON::Tiny::X::JSON::Tiny::Invalid` on malformed input, despite the
distribution declaring no dependency on JSON::Tiny.
