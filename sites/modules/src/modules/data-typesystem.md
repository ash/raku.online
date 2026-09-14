---
name: Data::TypeSystem
version: 0.1.8
auth: zef:antononcube
kind: Distribution · data
summary: Says what shape a data structure is — a vector of Ints, a tuple, a
  list of records, a hash of vectors — in one call, so code that accepts
  "data" can check it was handed a table before treating it as one.
status: full
suite: 4 files, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/zef:antononcube/Data::TypeSystem
source: https://github.com/antononcube/Raku-Data-TypeSystem
---

## What it is for

Raku's types stop at the container: an array of hashes, a hash of arrays and
a ragged list of lists are all just `Array` and `Hash`, and a routine that
wants "a dataset" has to poke at the first element and hope. This
distribution looks at the whole value and names its shape in a small
vocabulary — `Atom` for a scalar, `Vector` for a homogeneous list with its
length, `Tuple` for a mixed one with each element's type, `Assoc` for a hash
with its key and value types, `Struct` for a hash read as a record with named
fields.

It is the type layer under the author's data stack (`Data::Reshapers`,
`Data::Summarizers` and the rest), where every routine begins by asking what
it was given, and thirteen distributions depend on it.

## Naming a shape

```raku name="deduce"
use Data::TypeSystem;

say deduce-type([1, 2, 3]);
say deduce-type([1, 'a', 2]);
say deduce-type({ name => 'Ada', born => 1815 });
say deduce-type([{ x => 1, y => 2 }, { x => 3, y => 4 }]);
say deduce-type([[1, 2], [3, 4], [5, 6]]);
say deduce-type([[1, 2], [3]]);
say deduce-type({ a => [1, 2], b => [3, 4] });
say deduce-type([1, 'a', 2, 'b'], :tally);
say is-reshapable([[1, 2], [3]]);
```

```output
Vector(Atom((Int)), 3)
Tuple([Atom((Int)), Atom((Str)), Atom((Int))])
Struct([born, name], [Int, Str])
Vector(Assoc(Atom((Str)), Atom((Int)), 2), 2)
Vector(Vector(Atom((Int)), 2), 3)
Tuple([Vector(Atom((Int)), 2), Vector(Atom((Int)), 1)])
Assoc(Atom((Str)), Vector(Atom((Int)), 2), 2)
Tuple([Atom((Int)) => 2, Atom((Str)) => 2], 4)
False
```

The result is an object, and `say` shows its `gist`; the same value answers
`~~` against the type classes (`Data::TypeSystem::Vector` and friends) when
a routine wants to branch on it rather than print it. `:tally` folds a Tuple's
element types into counts, which is the readable form for anything long.
`is-reshapable` is the yes-or-no version of the question a table-building
routine asks: are all the rows the same length, or all the records the same
size.

## The one thing to know

It is a summary of types, not a schema. Two hashes with *different keys* but
the same key and value types make the same `Assoc`, and a list of them is a
`Vector` — and reshapable — just as if the keys matched:

```raku name="blind-spots"
use Data::TypeSystem;

say deduce-type([{ x => 1, y => 2 }, { x => 3, z => 4 }]);
say is-reshapable([{ x => 1, y => 2 }, { x => 3, z => 4 }]);
say deduce-type([True, False]);
say deduce-type([2.5e0, 1e0]);
```

```output
Vector(Assoc(Atom((Str)), Atom((Int)), 2), 2)
True
Vector(Atom((Int)), 2)
Vector(Atom((Numeric)), 2)
```

So a column named `y` in one record and `z` in the next passes as a tidy
table here, and turns into a hole further down. The last two lines are the
other edge of the vocabulary: a `Bool` is reported as an `Int` (which it is,
by inheritance) and a `Num` as `Numeric` rather than by its own name. Neither
is wrong, but a check written as `Atom((Num))` will never match.
