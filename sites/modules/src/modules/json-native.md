---
name: JSON::Native
version: 0.0.1
auth: zef:ash
kind: Distribution · data format
summary: JSON::Fast's interface with a native fast path — a C extension
  compiled at install time, or Raku++'s own codec — and JSON::Fast itself
  everywhere else. Same program, same answers, on both engines.
status: full
license: Artistic-2.0
depends: JSON::Fast
suite: 2 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:ash/JSON::Native
source: https://github.com/ash/raku-modules
---

## What it is for

The same job as [JSON::Fast](/modules/json-fast/), whose page sits next to
this one: JSON in, Raku data out, and back again. The interface is
JSON::Fast's on purpose — the same two subs, the same adverbs, the same
answers. What `use JSON::Native` adds is a promise about *how*: parsing and
serialising run native where something native exists to run, and fall back to
`JSON::Fast` where it does not, so one program leans on native speed under
Raku++ and runs unchanged under Rakudo.

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
100 gives exactly `314`, no floating-point tail. And that `to-json` call names
`:sorted-keys`, an adverb the native path does not claim, so it was answered
by `JSON::Fast` itself — same string either way, which is the whole contract.

## Three backends, and who is answering

`from-json` and `to-json` are served by the first of three backends that
exists, and `json-backend` tells you which one that was:

- **native** — the C extension this distribution ships as *source* and
  compiles against Raku++'s extension ABI while it installs;
- **engine** — Raku++ with no compiled extension: `from-json` still runs
  native, through the interpreter's own built-in codec, no C compiler needed;
- **JSON::Fast** — Rakudo, and anywhere else. Nothing breaks; it costs speed,
  never function.

```raku sample name="backend"
use JSON::Native;

say json-backend;
```

```output
native
```

That run is labelled a sample because it is the one line of this page whose
answer is *meant* to vary: under Rakudo it says `JSON::Fast`, and under Raku++
it says what the install could build — `native` here, the compiled extension
loaded back out of the store. For one day it said `engine`: the extension
compiled during `rakupp install`, but the store received the empty placeholder
the build starts from rather than the built library, and the module ran on the
middle rung — `from-json` still native through the interpreter's own parser,
`to-json` standing aside for `JSON::Fast`, whose calls Raku++ fast-paths
anyway. Nothing on this page printed a byte differently while it did, which is
the point of the ladder: a backend is a speed, never an answer. What that gap
was, and where it is pinned, is recorded at the end of this page.

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

## Byte for byte, checked against the original

A serialiser's exact output is a contract programs already depend on, so the
native path's output is `JSON::Fast`'s down to the choice of escape — and you
can check that claim the same way the test suite does, by asking `JSON::Fast`
itself. The `do { use … }` trick works because `use` is lexically scoped: the
import lives inside the block, hands back its `&to-json`, and never collides
with the one this module exports.

```raku name="byte-for-byte"
use JSON::Native;

my &reference = do { use JSON::Fast; &to-json };

my $value = ["back\bspace", "𝄞", 2.5];
say to-json($value, :!pretty);
say to-json($value, :!pretty) eq reference($value, :!pretty);
say from-json(to-json($value))[1] eq "𝄞";
```

```output
["back\u0008space","\uD834\uDD1E",2.5]
True
True
```

Both quirks in that first line are inherited deliberately: backspace is
written as the six-character `\u0008` rather than the shorter `\b`, and the
G-clef — outside the Basic Multilingual Plane — goes out as `\uD834\uDD1E`,
the surrogate pair JSON requires, and comes back as one character.

## `:immutable` is claimed; everything else is delegated

The native parser takes the text plus one adverb, `:immutable`, which answers
`Map` and `List` instead of `Hash` and `Array` — parsed configuration is read
many times and written never, and this way an accidental assignment fails at
the moment of the mistake:

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

Every *other* adverb — `:allow-jsonc` today, whatever `JSON::Fast` grows
next — is delegated to `JSON::Fast` untouched, never refused:

```raku name="delegate"
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

That rule was learned, not designed: an early version answered an unknown
adverb with `Unexpected named argument`, which made `use JSON::Native` a
downgrade from the module it stands in for. Being exactly right or standing
aside is the whole bargain; being approximately right would be worse than
being slow.

## The XS pattern, for Raku++

The distribution carries `src/json.c` and no binary. At install time a build
hook compiles it against Raku++'s extension ABI — the headers a released
Raku++ installs as `<prefix>/include/rakupp/rakupp_ext.h`, or a checkout's,
pointed at with `RAKUPP_SRC`. The compiled library resolves its `rk_*` symbols
from the host executable at load time, the way a Python C extension does. And
if any of that is missing — no compiler, no headers, no Raku++ at all — the
build leaves a stub, the install still succeeds, and the module runs on its
fallbacks.

The extension pays an ABI tax: every value crosses as an opaque handle and is
copied once into its container. That is the price of a compiled library
outliving the engine release it was built against, and it is the right trade —
with ABI 2's O(1) hash walk the extension outruns the engine's own in-tree
codec anyway.

## Speed, measured

Measured for the distribution's README on 2026-08-23 — a 278 KB document,
escaped and non-ASCII strings included, best of N. (The JSON::Fast page on
this site measures a different corpus, so compare ratios, not cells.)

| | parse | serialise |
|---|---|---|
| Rakudo + `JSON::Fast` | 42.0 ms | 41.3 ms |
| Raku++ + `JSON::Fast` (engine fast path) | ~6 ms | 6.1 ms |
| Raku++ + `JSON::Native`, engine backend | 7.7 ms | 2.5 ms |
| Raku++ + `JSON::Native`, extension | **5.0 ms** | 3.5 ms |

The engine-backend serialise cell is `JSON::Fast` doing the writing — that
backend delegates `to-json`, so the cell is the engine fast path writing this
module's parsed data. And the numbers scale: parse holds ~50–55 MB/s and
serialise ~72 MB/s from 278 KB up to 4.5 MB, linear at every rung — worth
stating, because a table at a single size is exactly the shape of benchmark
that cannot tell you.

## Where the two engines differ

One printed line on this page: `json-backend`, the sample above — and that
difference is the module's reason to exist. Everything else is identical by
contract, and the contract is enforced rather than hoped for: the
distribution's own suite compares values, types and serialised bytes against
`JSON::Fast` itself on whichever engine is running, and this site runs every
example here under both engines, twice on each, every time it is built.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install JSON::Native`, which pulls
   [JSON::Fast](/modules/json-fast/) with it and compiles the extension.
3. **Test** — the distribution's own suite: 2 files, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

Disclosure, as on every page where it applies: this distribution and the
engine share an author. The module exists partly as proof that Raku++'s
extension ABI carries a real XS-style workflow — C source in the archive, a
compile at install time, graceful fallback everywhere else. Nothing in the
module had to be fixed to put this page here — but putting it here found one
bug beside it. The engine's installer copied each declared resource by its
logical name, `libraries/json`, while a build hook writes the platform's
spelling, `libjson.dylib` — so the compiled extension never left the build
directory, the store served the empty placeholder, and the installed module
answered `engine`. The ladder absorbed it so completely that it took this
page's sample line to notice. It is fixed the same day it was found: the
installer now applies the same platform mapping `%?RESOURCES` applies on
lookup, records the file under both spellings so a Rakudo reading the shared
store finds it too, and the fix is pinned by the `native-lib` checks in the
engine's installer gate (`t/install/run.raku`). The sample above says what the
store serves now.
