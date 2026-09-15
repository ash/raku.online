---
name: JSON::Unmarshal
version: 0.18
auth: zef:raku-community-modules
kind: Distribution · data format
summary: JSON into typed objects — matching keys to public attributes,
  recursing into nested classes and typed arrays, and checking each value
  against the attribute's declared type.
status: full
suite: 11 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: JSON::Fast, JSON::Name, JSON::OptIn
raku-land: https://raku.land/zef:raku-community-modules/JSON::Unmarshal
source: https://github.com/raku-community-modules/JSON-Unmarshal
---

## What it is for

Parsing JSON gives you hashes and arrays. Most programs want something
further along than that: an object whose attributes have types, so the rest
of the code can stop checking. This distribution is the step between —
given a target type and a document, it builds an instance, matching keys to
public attributes, descending into attributes whose own types are classes,
and filling a typed array with typed elements.

It is the reading half of a pair whose writing half is `JSON::Marshal`, and
the two are usually met together through `JSON::Class`, which composes both
onto a class.

## Documents into objects

```raku name="into-objects"
use JSON::Unmarshal;

class Point { has Int $.x; has Int $.y }
class Box {
    has Str    $.label;
    has Point  $.corner;
    has Point  @.points;
    has Bool   $.active;
}

my $box = unmarshal(
    '{"label":"b1","corner":{"x":1,"y":2},"points":[{"x":3,"y":4}],"active":true}',
    Box);
say $box.label, ' ', $box.active;
say $box.corner.^name, ' at ', $box.corner.x, ',', $box.corner.y;
say $box.points.elems, ' ', $box.points[0].^name;

say unmarshal('[1,2,3]', Array[Int]).raku;
say unmarshal({ x => 5, y => 6 }, Point).x;
```

```output
b1 True
Point at 1,2
1 Point
(1, 2, 3)
5
```

The nested object is a `Point`, not a hash, and so is the element inside
the array — that recursion is the whole value of the module. It takes an
already-parsed hash or array too, which is what you want when the JSON came
from somewhere that already decoded it.

A value of the wrong type is refused rather than coerced, and an unexpected
key is ignored unless you ask otherwise:

```raku name="type-checks"
use JSON::Unmarshal;

class Person { has Str $.name; has Int $.born }

say (try unmarshal('{"born":"not a number"}', Person)) // $!.^name;
say unmarshal('{"name":"Ada","unexpected":1}', Person).name;
say (try unmarshal('{"unexpected":1}', Person, :die)) // $!.^name;
say unmarshal('{}', Person).born.defined;
```

```output
JSON::Unmarshal::X::CannotUnmarshal
Ada
JSON::Unmarshal::X::UnusedKeys
False
```

## The one thing to know

The type checking is asymmetric, and the lenient direction is silent even
under `:die`:

```raku name="asymmetric"
use JSON::Unmarshal;

class Record { has Str $.id; has Int $.count; has Bool $.on }

say (try unmarshal('{"count":"42"}', Record)) // 'string into Int: throws';

say unmarshal('{"id":12345}', Record).id.defined;
say unmarshal('{"id":12345}', Record, :die).id.defined;

say unmarshal('{"on":"false"}', Record).on;
```

```output
string into Int: throws
False
False
True
```

A JSON string arriving at an `Int` attribute throws, which is right. A JSON
*number* arriving at a `Str` attribute is dropped and the attribute left
undefined — with no warning, under any error mode, including `:die`. So a
document with `"id": 12345` where your class says `Str $.id` produces an
object that looks fine and has no identifier, and you find out somewhere
much later.

The last line is the same leniency biting harder. `Bool` is built by
coercion, and every non-empty string is true — so `"false"`, the string,
unmarshals to `True`. Any producer that stringifies its booleans will be
read inverted half the time. Declare such fields as `Str` and convert them
yourself.

Two smaller things: a misspelled option is a warning rather than an error
unless you also passed `:die`, and the `Array` and `Hash` target forms use
`fail` rather than throwing, so a shape mismatch hands back a `Failure`
that only explodes when you use it.
