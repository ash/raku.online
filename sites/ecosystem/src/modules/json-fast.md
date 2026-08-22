---
name: JSON::Fast
version: 0.20.1
auth: zef:timo
kind: Distribution · data format
summary: JSON in, Raku data out, and back again. Two exported subs, a handful
  of adverbs, and the numbers come back typed the way you would have typed them.
status: full
license: Artistic-2.0
suite: 14 files, green
tested: 2026-08-22
raku-land: https://raku.land/zef:timo/JSON::Fast
source: https://github.com/timo/json_fast
---

## What it is for

Something handed you JSON — a config file, an HTTP response, a line off a
queue — and you want it as a Hash you can index. Or you have a Hash and
something else wants JSON. That is the whole job, and this module is two subs
wide:

```raku name="tour"
use JSON::Fast;

my %config = from-json('{"name":"raku","stars":3,"tags":["fast","fun"]}');
say %config<name>;
say %config<tags>.join(', ');
say to-json({ ok => True, count => 2 }, :sorted-keys, :!pretty);
```

```output
raku
fast, fun
{"count":2,"ok":true}
```

It has no dependencies outside the core, which is why 170 other distributions
depend on *it* — more than three times the runner-up. If you install one module
from the ecosystem, it is probably this one, and if you install any other, this
one likely comes along.

## Reading: the types you get back

`from-json` is not a stringly parser. A JSON number arrives as the Raku numeric
type that can hold it exactly — an integer as `Int`, a decimal as `Rat`, and
only a number written with an exponent as the lossy `Num`:

```raku name="types"
use JSON::Fast;

my %n = from-json('{"i":42,"r":3.5,"e":1e3,"big":123456789012345678901234567890}');
say %n<i>.^name,   ' ', %n<i>;
say %n<r>.^name,   ' ', %n<r>;
say %n<e>.^name,   ' ', %n<e>;
say %n<big>.^name, ' ', %n<big>;
```

```output
Int 42
Rat 3.5
Num 1000
Int 123456789012345678901234567890
```

Two of those lines are the reason to prefer this module to hand-rolled
parsing. `3.5` stays a `Rat`, so money and percentages survive arithmetic
without a floating-point tail. And a number too big for a machine word becomes
an arbitrary-precision `Int` rather than silently rounding — the JSON spec puts
no ceiling on an integer literal, and neither does Raku.

`true`/`false` come back as `Bool`, `null` as `Any`, an object as a `Hash` and
an array as an `Array`.

## Writing: `to-json` and its three adverbs

By default `to-json` pretty-prints with two spaces:

```raku name="pretty"
use JSON::Fast;

print to-json({ name => 'raku', tags => <fast fun> }, :sorted-keys);
```

```output
{
  "name": "raku",
  "tags": [
    "fast",
    "fun"
  ]
}
```

`:!pretty` puts it all on one line — what you want on a wire. `:spacing($n)`
changes the indent. `:sorted-keys` sorts object keys, and it is worth reaching
for by reflex: a Hash has no order, so without it the same data serialises
differently from run to run, and a diff of two config dumps becomes noise.

```raku name="spacing"
use JSON::Fast;

print to-json({ a => 1, b => [2, 3] }, :sorted-keys, :spacing(4));
```

```output
{
    "a": 1,
    "b": [
        2,
        3
    ]
}
```

The adverbs can also be set once, at the `use`, for every call in that scope —
an import list of option names, `!` to switch one off:

```raku name="import-form"
use JSON::Fast <immutable !pretty>;

my $d = from-json('{"a":1}');
say $d.^name;
say to-json({ a => 1 });
```

```output
Map
{"a":1}
```

## `:immutable` — a result nobody can edit under you

Parsed JSON is usually configuration: read many times, written never. Ask for
it `:immutable` and you get `Map` and `List` instead of `Hash` and `Array`, so
an accidental assignment fails loudly at the moment of the mistake rather than
somewhere downstream:

```raku name="immutable"
use JSON::Fast;

my $d = from-json('{"a":[1,2]}', :immutable);
say $d.^name;
say $d<a>.^name;
say (try { $d<a>[0] = 9; 'assigned' }) // 'refused';
```

```output
Map
List
refused
```

## JSON with comments

Configuration files grow comments whether or not the format allows them.
`:allow-jsonc` accepts both comment styles, so a hand-maintained file can
explain itself:

```raku name="jsonc"
use JSON::Fast;

my $text = q:to/JSONC/;
    {
        // the name of the thing
        "name": "raku",
        /* and how many stars it has */
        "stars": 3
    }
    JSONC

say from-json($text, :allow-jsonc)<name stars>.join(' ');
```

```output
raku 3
```

## When the text is wrong

Text that is not JSON throws. The one failure worth catching by type is text
that *starts* as valid JSON and then keeps going — a doubled response, a file
with two documents in it — because the exception says where the good part
ended:

```raku name="errors"
use JSON::Fast;

my $text = '{"a":1} trailing junk';
my $data = try from-json($text);
with $! {
    say .^name;
    say .rest-position;
    say $text.substr(.rest-position).trim;
}
```

```output
X::JSON::AdditionalContent
8
trailing junk
```

`.rest-position` counts **graphemes**, not bytes, so it indexes straight back
into the string you passed — as it does above.

## Unicode, and the pair of escapes above U+FFFF

Strings survive the round trip, including characters outside the Basic
Multilingual Plane, which JSON can only spell as a surrogate pair:

```raku name="unicode"
use JSON::Fast;

my $json = to-json({ text => "möp stüff — 𝄞" }, :!pretty);
say $json;
say from-json($json)<text>;
say from-json($json)<text> eq "möp stüff — 𝄞";
```

```output
{"text":"möp stüff — \uD834\uDD1E"}
möp stüff — 𝄞
True
```

The G-clef went out as `\uD834\uDD1E` — the surrogate pair JSON has to use for
anything above U+FFFF — and came back as one character. That last `True` is a
stricter claim than it looks. The engine composes
combining marks when it joins strings, and the module round-trips text through
NFD codepoints and back — for a while under Raku++ the two disagreed, and
`"möp stüff"` came back decomposed while `.ords` looked identical on both
sides. It is the kind of bug that hides in plain sight; the assertion is on
this page on purpose.

## Speed, measured

The module is called Fast because it is fast under Rakudo. Under Raku++ it is
slower, and by how much is worth knowing before you point it at a large file.
Parsing the 325 KB SPDX license list that `License::SPDX` ships:

| | Raku++ 3.6.0 | Rakudo 2026.07 |
|---|---|---|
| 325 KB, 3 top-level keys | ~450–510 ms | ~50–70 ms |

About 8×, and it scales linearly on both — a file twice the size costs about
twice as much, not four times. That last property was bought once and is worth
naming, because for one release it was not true: `Value` copied its `Str` by
value on every argument pass, and the nqp scanning ops re-derived the scan
prefix per character, which made *any* Raku tokenizer quadratic. A 421 KB parse
took 13,969 ms. With copy-on-write strings and the scan cached on the shared
body it takes 764 ms, and the curve is straight.

For a while Raku++ shipped a C++ JSON parser under this module's name, which
made the same parse 5 ms — and pinned every user to version 0.19 whatever they
had installed, silently. That was the wrong trade and it was reversed in
v3.0.1. `use JSON::Fast` loads the author's module from disk and parses as
ordinary Raku, and the number above is what ordinary Raku costs today.

## Where the two engines differ

Nothing on this page. Every example above prints the same bytes under Raku++
and under Rakudo, twice on each, and the site build fails if that stops being
true.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install JSON::Fast`, no dependencies to pull.
3. **Test** — the distribution's own suite: 14 files, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

Getting the suite green took ten engine fixes, and not one of them was about
JSON. The module is nqp-heavy, so its tests reach the runtime's lowest layers:
a repeated `use` never re-ran a module's `EXPORT` sub, so `use JSON::Fast
<immutable !pretty>` in one block and a plain `use JSON::Fast` in the next got
the first block's bindings or none; enum values did not do `Enumeration` and an
enum type object came back *defined*, which made the module render it as
`null`; `nqp::create` matched class names by their full name, so a `my class …
is repr("VMHash")` declared inside a module got a buffer instead of a hash and
every key vanished; an `augment` of a built-in class shadowed the built-in
instead of adding to it; and a hyper around a user-defined infix, `@a »=~=«
@b`, failed twice over — once in the parse, once in reading the trailing `=` as
a compound assignment.

The one that was hardest to see is the one asserted above: `~` composed
combining marks but `.join`, `nqp::join`, `nqp::concat` and
`nqp::strfromcodes` did not. JSON::Fast round-trips strings through NFD
codepoints and back, so `"möp stüff"` came out byte-decomposed while `.ords`
looked identical on both sides, and only `eq` disagreed.
