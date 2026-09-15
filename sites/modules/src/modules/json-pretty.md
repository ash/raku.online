---
name: JSON::Pretty
version: 0.1.1
auth: zef:raku-community-modules
kind: Distribution · data format
summary: A `to-json` that formats for a human — one value per line, two
  spaces of indent, a space either side of the colon — imported over the
  one you already have.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: JSON::Fast
raku-land: https://raku.land/zef:raku-community-modules/JSON::Pretty
source: https://github.com/raku-community-modules/JSON-Pretty
---

## What it is for

JSON that a person is going to read — a config file the program writes
back, a fixture checked into a repository, a dump while debugging — wants
generous whitespace and one value per line, so that a diff shows the line
that changed rather than the whole document. JSON that a program is going
to read wants none of that.

This distribution is the first kind. It re-implements the encoder with a
fixed layout and leaves decoding to `JSON::Fast`, which it passes straight
through.

## Formatted output

```raku name="pretty"
use JSON::Pretty;

say to-json({ outer => [ 1, { inner => 'v' }, [ ] ] });
say to-json([1, 2]);
say to-json(42).raku;
say to-json('hi').raku;
say to-json(Any).raku;
say to-json({}).raku;
say to-json([]).raku;

say from-json('{"a":[1,2,{"b":null}]}')<a>[2]<b>.raku;
```

```output
{
  "outer" : [
    1,
    {
      "inner" : "v"
    },
    [ ]
  ]
}
[
  1,
  2
]
"42"
"\"hi\""
"null"
"\{ }"
"[ ]"
Any
```

The shape is fixed: two spaces per level, one element per line, and a space
either side of the key's colon — which is the layout the module exists to
produce and the reason to reach for it rather than `JSON::Fast`'s own
`:pretty`. Note the two empty containers: they come out as `[ ]` and `{ }`,
with a space inside, which is valid JSON and will not match a byte
comparison against any other encoder.

## The one thing to know

`use JSON::Pretty;` does not give you a new function. It **replaces**
`to-json` with a different one that has a different signature, and every
option you might reflexively pass is gone:

```raku name="replaces"
use JSON::Pretty;

say &to-json.name;
say &from-json.name;

say (try to-json({ a => 1 }, :sorted-keys)) // 'sorted-keys: refused';
say (try to-json({ a => 1 }, :!pretty))     // 'pretty: refused';

my $point = class { has $.x; has $.y }.new(x => 1, y => 2);
say (try to-json($point)) // 'an object: refused';
```

```output
pretty-json
from-json
sorted-keys: refused
pretty: refused
an object: refused
```

There is no way to turn the formatting off, no `:sorted-keys`, and no
`:spacing`. In a file that already says `use JSON::Fast;`, adding this
module re-binds `to-json` underneath existing call sites, and they break at
run time rather than at compile time.

The missing `:sorted-keys` is the one that bites hardest, because hash
order is not reproducible: under Rakudo it is randomised per process, so
the same data gives a different file on every run. That defeats the diffing
this module exists to make possible. If the output has to be stable, sort
the structure into an ordered form before encoding it, or use
`JSON::Fast`'s encoder with both `:pretty` and `:sorted-keys` and accept a
slightly different layout.

The last line is the other limit: anything that is not a string, number,
boolean, list or hash is refused outright. There is no hook and no trait —
convert your objects to plain data yourself first.
