---
name: JSON::Marshal
version: 0.0.25
auth: zef:jonathanstowe
kind: Distribution · data format
summary: An object's public attributes turned into JSON, with four traits
  for the per-attribute decisions — skip it, skip it when empty, run it
  through a converter, or publish only what is marked.
status: full
suite: 14 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: JSON::Fast, JSON::Name, JSON::OptIn
raku-land: https://raku.land/zef:jonathanstowe/JSON::Marshal
source: https://github.com/jonathanstowe/JSON-Marshal
---

## What it is for

Writing an object out as JSON is a walk over its public attributes, and it
is nearly always *nearly* right — except for the password you must not
publish, the timestamp that needs formatting first, and the optional field
that should be absent rather than null. Those three exceptions are why a
generic serialiser needs per-attribute control, and this distribution
provides it as traits on the attributes themselves.

It is the writing half of the pair whose reader is `JSON::Unmarshal`.

## Objects into documents

```raku name="into-json"
use JSON::Marshal;

class Point { has Int $.x; has Int $.y }
class Box {
    has Str   $.label;
    has Point $.corner;
    has Point @.points;
    has       %.meta;
}

my $box = Box.new(
    label  => 'b1',
    corner => Point.new(x => 1, y => 2),
    points => (Point.new(x => 3, y => 4),),
    meta   => { z => 9 },
);
say marshal($box, :!pretty, :sorted-keys);

say marshal(42, :!pretty);
say marshal('hi', :!pretty);
say marshal([1, 2, 3], :!pretty);
say marshal(Int, :!pretty);
```

```output
{"corner":{"x":1,"y":2},"label":"b1","meta":{"z":9},"points":[{"x":3,"y":4}]}
42
"hi"
[1,2,3]
null
```

Nested objects, arrays of objects and plain hashes all recurse, so one call
handles the whole tree. It will serialise non-objects too, which is
occasionally handy and mostly a sign you meant to call the JSON writer
directly.

The four traits cover the per-attribute cases:

```raku name="traits"
use JSON::Marshal;

class Account {
    has Str $.user;
    has Str $.token    is json-skip;
    has Str $.nickname is json-skip-null;
    has Str $.created  is marshalled-by('uc');
    has Str $.tag      is marshalled-by(-> $v { "<<$v>>" });
}

my $a = Account.new(user => 'ada', token => 'secret',
                    created => 'monday', tag => 'x');
say marshal($a, :!pretty, :sorted-keys);
say marshal($a, :!pretty, :sorted-keys, :skip-null);
```

```output
{"created":"MONDAY","tag":"<<x>>","user":"ada"}
{"created":"MONDAY","tag":"<<x>>","user":"ada"}
```

`is json-skip` keeps the token out entirely. `is json-skip-null` drops the
nickname only when `:skip-null` is on and it has no value.
`is marshalled-by` takes either a method name to call on the value or a
closure to pass it through, which is where a `DateTime` becomes a string.

## The one thing to know

`marshal` pretty-prints by default. `:pretty` is `True` in the signature,
which is the opposite of what almost every other serialiser does:

```raku name="pretty-default"
use JSON::Marshal;

class Small { has Int $.n }

say marshal(Small.new(n => 1)).lines.elems, ' lines by default';
say marshal(Small.new(n => 1), :!pretty);
say marshal(Small.new(n => 1), :!pretty).chars, ' characters compact';
```

```output
3 lines by default
{"n":1}
7 characters compact
```

A one-attribute object is three lines unless you say otherwise, so anything
going onto a wire, into a database column or through a hash function needs
`:!pretty` explicitly. Every example on this page passes it.

The companion default is worth the same attention: without `:sorted-keys`
the key order is hash order, which under Rakudo is randomised per process.
So the same object serialises differently on two runs, which defeats
diffing, caching by content, and golden-file tests. Pass both.

One more thing that catches people using `:opt-in`: three of the four
traits above quietly *add* their attribute to the opted-in set, because
each composes the marker role that `JSON::OptIn` defines. Only
`is json-skip` does not. So a class that renames one attribute and
formats another has already chosen its `:opt-in` set without meaning to.
