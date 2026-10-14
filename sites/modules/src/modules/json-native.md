---
name: JSON::Native
version: 0.1.0
auth: zef:ash
kind: Distribution · data format
summary: JSON::Fast's interface and answers, byte for byte, on each engine's
  fastest exact path — Raku++'s built-in codec, the JSON reader Rakudo carries —
  and pure Raku everywhere else. No C, no dependencies, and on Raku++ 5.4
  nothing to install.
status: full
license: Artistic-2.0
depends: none beyond the core
suite: 5 files, green
tested: 2026-10-14
engine: Raku++ 5.4.1
oracle: Rakudo 2026.09
raku-land: https://raku.land/zef:ash/JSON::Native
source: https://github.com/ash/raku-modules/tree/main/JSON-Native
---

## What it is for

The same job as [JSON::Fast](/modules/json-fast/), whose page sits next to
this one: JSON in, Raku data out, and back again. The interface is
JSON::Fast's on purpose — the same two subs, the same adverbs, the same import
options, the same answers — so a program switches by changing its `use` line.
What `use JSON::Native` adds is a promise about *how*: on each engine the
work runs on the fastest path that engine has which gives exactly JSON::Fast's
answers, and nothing else has to be installed for it — no C compiler, and not
JSON::Fast. On Raku++ 5.4.0 and newer the engine answers `use JSON::Native`
itself, so the module does not even need to be installed there.

```raku name="tour"
use JSON::Native;

my $data = from-json('{"name":"raku","versions":[6,"d"],"fast":true,"pi":3.14}');
say $data<name>;
say $data<versions>[1];
say $data<fast>.^name;
say $data<pi> * 100;
say to-json($data, :!pretty, :sorted-keys);
```

```output
raku
d
Bool
314
{"fast":true,"name":"raku","pi":3.14,"versions":[6,"d"]}
```

The numbers come back as Raku numerics — `3.14` is a `Rat`, so multiplying by
100 gives exactly `314`, no floating-point tail. And `to-json` takes
JSON::Fast's adverbs: `:!pretty` for one line, `:sorted-keys` for an order
that does not depend on how a hash happens to iterate.

## Which path answers, on which engine

Each engine loads only what its own path needs:

| engine | parses with | writes with |
|---|---|---|
| Raku++ | the engine's built-in codec | the same codec |
| Rakudo | `Rakudo::Internals::JSON`, the copy of JSON::Fast Rakudo carries for zef | `JSON::Native::Rakudo`, a writer in `nqp::` ops |
| mutsu | the JSON::Fast mutsu ships | the same |
| any other | `JSON::Native::Raku`, the module's pure-Raku port of JSON::Fast | the same |

Behind every fast path stands `JSON::Native::Raku`, loaded by the first call
that needs it and by no other: whatever a fast path does not take — an adverb
it lacks, a type outside the JSON ladder, a document it refuses — is handed
there, so the answer is JSON::Fast's either way. On Raku++ the engine carries
its own copy of that file inside the binary, which is why nothing needs to be
installed. `json-backend` names the path that parses:

```raku sample name="backend"
use JSON::Native;

say json-backend;
```

```output
engine
```

That run is labelled a sample because it is the one line of this page whose
answer is *meant* to vary: `engine` under Raku++, `rakudo` under Rakudo,
`json-fast` under mutsu, `raku` anywhere else; `json-backend(:write)` names
the path that writes. For testing and diagnosis, `JSON_NATIVE_BACKEND` asks
for one path by name. A backend is a speed, never an answer: nothing else on
this page prints a byte differently on either engine.

## The types you get back are JSON::Fast's

Checked value by value, because "compatible" is a claim about types, not just
about values:

```raku name="types"
use JSON::Native;

my %n = from-json('{"i":42,"r":0.1,"e":2e3,"big":123456789012345678901234567890}');
say %n<i>.^name, ' ', %n<i>;
say %n<r>.^name, ' ', %n<r> + 0.2 == 0.3;
say %n<e>.^name;
say %n<big> + 1;
```

```output
Int 42
Rat True
Num
123456789012345678901234567891
```

An integer token is an `Int` of arbitrary precision — the last line does exact
arithmetic on a number no machine word holds. A decimal is a `Rat`, which is
why `0.1 + 0.2 == 0.3` is `True` here and famously is not in float-land. Only
an exponent form becomes the lossy `Num`. `true`/`false` are `Bool`, `null` is
`Any`, objects and arrays are `Hash` and `Array`.

## Byte for byte, quirks included

A serialiser's exact output is a contract programs already depend on, so
`to-json` writes JSON::Fast's text down to the choice of escape:

```raku name="byte-for-byte"
use JSON::Native;

my $value = ["back\bspace", "𝄞", 2.5];
say to-json($value, :!pretty);
say from-json(to-json($value))[1] eq "𝄞";
say to-json([]).raku;
```

```output
["back\u0008space","\uD834\uDD1E",2.5]
True
"[\n]"
```

All three quirks are inherited deliberately: backspace is written as the
six-character `\u0008` rather than the shorter `\b`; the G-clef — outside the
Basic Multilingual Plane — goes out as `\uD834\uDD1E`, the surrogate pair JSON
requires, and comes back as one character; and an empty array, pretty-printed,
is `[` and `]` on two lines.

The claim is checked, not hoped for. The distribution's suite holds
JSON::Fast's answers for some 125 documents and 440 value-and-adverb
combinations, written down by JSON::Fast itself, and checks every one on every
engine and every path. Where JSON::Fast is installed, `t/04-json-fast.t` also
asks it live, over 600 random documents and random corruptions of them — on
Rakudo. On Raku++ that file skips itself: there, an installed JSON::Fast's
subs are wrapped by the same codec, and the comparison would be the engine
against itself.

## `:immutable`, and the import options

`from-json` takes JSON::Fast's `:immutable`, which answers `Map` and `List`
instead of `Hash` and `Array` — parsed configuration is read many times and
written never, and this way an accidental assignment fails at the moment of
the mistake:

```raku name="immutable"
use JSON::Native;

my $config = from-json('{"a":[1,2]}', :immutable);
say $config.^name;
say $config<a>.^name;
say (try { $config<a>[0] = 9; 'assigned' }) // 'refused';
```

```output
Map
List
refused
```

JSON::Fast's import options work too: `use JSON::Native <immutable !pretty
sorted-keys enums-as-value>` changes the defaults of the subs it hands out,
with `!` turning one off, and an adverb at the call still wins:

```raku name="import-options"
use JSON::Native <!pretty sorted-keys>;

say to-json({ name => 'raku', tags => <fast exact>, note => Any });
say to-json({ name => 'raku' }, :pretty);
```

```output
{"name":"raku","note":null,"tags":["fast","exact"]}
{
  "name": "raku"
}
```

## Comments, and refusals in JSON::Fast's words

`:allow-jsonc` accepts `//` and `/* */` comments, as JSON::Fast's does:

```raku name="jsonc"
use JSON::Native;

my $text = q:to/JSONC/;
    {
        // not JSON, until you allow it
        "a": 1
    }
    JSONC
say from-json($text, :allow-jsonc)<a>;
```

```output
1
```

And a document that is not JSON is refused as JSON::Fast refuses it — the
same message, at the same position, on every engine — because a document a
fast path refuses is handed to the port, which refuses it in JSON::Fast's
words:

```raku name="refusals"
use JSON::Native;

for '[1,', "[\"a\tb\"]", '[1] [2]' -> $doc {
    try from-json($doc);
    say $!.^name, ': ', $!.message.lines.head;
}
```

```output
X::AdHoc: at end of input: expected a json object
X::AdHoc: this kind of whitespace is not allowed in a string: '"\t"' near 6
X::JSON::Native::AdditionalContent: JSON Input contained additional text after the document (parsed 3 chars, next non-whitespace lives at 4)
```

The raw TAB in the second document is refused because JSON::Fast refuses it —
while a raw CR, which RFC 8259 also forbids, is accepted, because JSON::Fast
accepts it. The last line is the one place the module and JSON::Fast differ:
content after the document raises `X::JSON::Native::AdditionalContent`, with
the same message and the same `parsed`, `parsed-length` and `rest-position`
attributes as JSON::Fast's `X::JSON::AdditionalContent`. Two distributions
cannot both declare one global class, so a `CATCH` that names JSON::Fast's
class needs this name instead.

That rule — exactly right, or hand the call to something that is — was
learned, not designed: an early version answered an unknown adverb with
`Unexpected named argument`, which made `use JSON::Native` a downgrade from
the module it stands in for. Being approximately right would be worse than
being slow.

## No C, and why

Up to 0.0.3 the distribution carried `src/json.c`, compiled at install time
against Raku++'s extension ABI, and depended on JSON::Fast for everything the
extension declined. 0.1.0 has neither. The engine's built-in codec had
overtaken the extension on every shape of document once it stopped typing
each number through the whole of `Str.Numeric`: on 200–850 KB documents of
only integers it went from 18 ms to 1.1 ms (the extension took 3.3), and on a
mixed 316 KB document from 13.5 ms to 2.6 (the extension took 3.8). Rakudo
needed no C either: the JSON reader it carries for zef already parses exactly
as JSON::Fast does — 6,000 documents, accepted and refused — at JSON::Fast's
speed. A NativeCall tokenizer for Rakudo was built and measured, and removed
a day later. So installing the module now compiles nothing and fetches
nothing. The [design
log](https://github.com/ash/raku-modules/blob/main/notes/JSON-Native.md) has
the measurements.

## Speed, measured

Measured for the distribution's README on 2026-10-13, on an Apple M4 MacBook
Air with Raku++ 5.3.0-85 and Rakudo v2026.09, on a 3.6 MB file of 10,000
records — integers, decimals, exponent forms, nested objects, `\u` escapes and
non-ASCII text — from the
[sample data](https://github.com/ash/raku-modules/tree/main/benchmarks/sample-data)
the module's repository keeps, so it can be re-run. Each cell is the fastest
and slowest of five separate runs, the two modules taking turns; where two
ranges overlap, the difference is noise. (The JSON::Fast page on this site
measures a different corpus, so compare ratios, not cells.)

| 10,000 records, 3.6 MB | parse | write |
|---|---:|---:|
| Raku++, `JSON::Fast` | 19.3–19.7 ms | 23.4–23.8 ms |
| Raku++, **`JSON::Native`** | 19.2–19.8 ms | 23.5–24.5 ms |
| Rakudo, `JSON::Fast` | 441–446 ms | 482–488 ms |
| Rakudo, **`JSON::Native`** | 433–437 ms | 337–346 ms |

The two Raku++ rows match because they run the same code: when a program says
`use JSON::Fast`, Raku++ loads the installed module and wraps its `from-json`
and `to-json` with the same built-in codec. What JSON::Native saves there is
the `use` — about 0.1 ms against about 5, since no module file is read — and
the install. On Rakudo, parsing is JSON::Fast's own code at JSON::Fast's
speed, and writing is the module's `nqp::` writer, in about 30% less time. A
single small call costs a little more on Rakudo, 6.6–6.8 µs against 5.4–5.5
for a one-record document: the extra call in front of the parser. The README
has the per-call figures, the 36 MB file, and mutsu.

## Where the two engines differ

One printed line on this page: `json-backend`, the sample above — and that
difference is the module's reason to exist. Everything else is identical by
contract, and the contract is enforced rather than hoped for: the
distribution's own suite compares values, types and serialised bytes against
JSON::Fast's recorded answers on whichever engine is running, and this site
runs every example here under both engines, twice on each, every time it is
built.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — under Raku++ 5.4.1, nothing: the engine answers `use
   JSON::Native`, claiming the module's interface version 0.1.0. It steps
   aside for an installed copy newer than that, for one named with `-I`, and
   when `JSON_NATIVE_BACKEND` asks for another path. Rakudo needs
   `zef install JSON::Native`, which fetches nothing else.
3. **Test** — the distribution's own suite: 5 files, green under both engines;
   `t/04-json-fast.t` skips itself under Raku++, for the reason given above.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

Disclosure, as on every page where it applies: this distribution and the
engine share an author, and the engine is more than a host here — it answers
this module's `use` itself and carries a copy of `JSON::Native::Raku`
(`rakulib/JSON/Native/Raku.rakumod` in the rakupp repository), kept equal to
the distribution's file by hand. The first version of this page, written for
0.0.2's C extension, found an engine bug beside it: the installer copied a
declared resource by its logical name, `libraries/json`, while the build hook
wrote the platform's spelling, `libjson.dylib`, so the compiled library never
reached the store. It was fixed the same day, and the fix is pinned by the
`native-lib` checks in the engine's installer gate (`t/install/run.raku`).
