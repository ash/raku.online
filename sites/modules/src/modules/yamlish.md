---
name: YAMLish
version: 0.1.3
auth: zef:leont
kind: Distribution · data format
summary: Read and write YAML — configuration files as people actually write
  them, with the type guessing that implies, and one famous trap.
status: full
license: Artistic-2.0
depends: MIME::Base64
suite: 5 files, green
tested: 2026-08-24
raku-land: https://raku.land/zef:leont/YAMLish
source: https://github.com/Leont/yamlish
---

## What it is for

YAML is the format configuration ends up in when a human has to edit it: no
braces, no quotes unless you need them, indentation carrying the structure.
`load-yaml` turns a document into ordinary Raku data:

```raku name="tour"
use YAMLish;

my $yaml = q:to/YAML/;
    name: raku
    version: 6.d
    tags:
      - fast
      - fun
    limits:
      depth: 3
      strict: true
    YAML

my %d = load-yaml($yaml);
say %d<name>;
say %d<tags>.join(', ');
say %d<limits><depth>.^name, ' ', %d<limits><depth>;
say %d<limits><strict>.^name;
```

```output
raku
fast, fun
Int 3
Bool
```

Mappings become `Hash`, sequences `Array`, and scalars are **typed by their
shape**, not left as strings: `3` is an `Int`, `true` is a `Bool`. That is the
convenience of YAML and, two sections down, its trap.

## Writing it back

`save-yaml` goes the other way. It quotes every string and every key, which is
verbose but never ambiguous:

```raku name="save"
use YAMLish;

print save-yaml({ name => 'raku', tags => <fast fun>, depth => 3 });
```

```output
---
"depth": 3
"name": "raku"
"tags": 
  - "fast"
  - "fun"
...
```

The `---` and `...` are the document start and end markers, and keys come out
sorted. Round-tripping a file through `load-yaml` and `save-yaml` therefore
does not preserve its layout — comments, key order and quoting style are all
lost. YAMLish is for reading configuration and writing data, not for editing
somebody's file in place.

## More than one document

A YAML stream may hold several documents separated by `---`. `load-yamls`
returns all of them:

```raku name="stream"
use YAMLish;

my $stream = q:to/YAML/;
    ---
    doc: 1
    ---
    doc: 2
    YAML

my @docs = load-yamls($stream);
say @docs.elems;
say @docs.map(*.<doc>).join(',');
```

```output
2
1,2
```

`save-yamls` is its counterpart for writing several out.

## What the scalars become

Worth reading once, because every one of these lines has surprised somebody:

```raku name="types"
use YAMLish;

my %d = load-yaml(q:to/YAML/);
    count: 42
    ratio: 0.5
    when: 2026-08-22
    nothing: ~
    text: "42"
    YAML

for <count ratio when nothing text> -> $k {
    say "$k: %d{$k}.^name() = %d{$k}.raku()";
}
```

```output
count: Int = 42
ratio: Rat = 0.5
when: Str = "2026-08-22"
nothing: Any = Any
text: Str = "42"
```

`0.5` is a `Rat`, not a `Num` — exact, like the rest of Raku's decimals. A date
stays a **string**: YAML's timestamp type is not resolved here, so parse it
yourself with `Date.new` if you want a `Date`. `~` is YAML's null and arrives as
an undefined `Any`. And `"42"` in quotes stays a string, which is how you keep
a version number or a zip code from turning into a number.

## The Norway problem

This is the one to know. YAML 1.1 treats `yes`, `no`, `on`, `off`, `true` and
`false` as booleans — **including when they are keys**:

```raku name="norway"
use YAMLish;

my %d = load-yaml("yes: true\nno: false\nname: raku\n");
say %d.keys.sort.map(*.raku).join(' ');
say %d{True}.raku;
```

```output
"False" "True" "name"
Bool::True
```

The keys `yes` and `no` did not survive as `yes` and `no`; they became `True`
and `False`. The same rule is why a country list containing Norway —
whose ISO code is `NO` — loses it unless it is quoted. Quote any key or value
that is one of those six words, and quote anything that only *looks* like a
number.

## What it does not do

Merge keys are not resolved. `<<: *base` is accepted as syntax but does not
merge the anchored mapping in — the merged-in keys are simply absent, on both
engines:

```raku name="anchors"
use YAMLish;

my %d = load-yaml(q:to/YAML/);
    defaults: &base
      retries: 3
      timeout: 30
    staging:
      <<: *base
      timeout: 5
    YAML

say %d<staging><retries>;
say %d<staging><timeout>;
```

```output
(Any)
5
```

`retries` came from the anchor and is gone; `timeout`, written out in full, is
there. If your configuration relies on merge keys, flatten it before handing it
to YAMLish, or merge the hashes yourself after loading —
[`Hash::Merge`](/modules/hash-merge/) does exactly that.

## Where the two engines differ

Nothing on this page. Every example prints the same bytes under Raku++ and
under Rakudo, twice on each.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install YAMLish`, which pulls `MIME::Base64` with it.
3. **Test** — the distribution's own suite: 5 files, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

YAMLish was one of the four distributions that already matched Rakudo when the
ecosystem campaign took its first measurement, so it did not need a rescue. It
earned its keep a different way: as the thing that **caught** two engine bugs
found while other modules were being fixed.

The first was a dispatch rule. YAMLish writes
`multi to-yaml(Str:D $d where /^ <!Schema::Core::element> …/)`, and when an
unrelated fix made that candidate selectable for the first time, scalars
started coming out unquoted. The cause was not the `where` clause: **a routine
that does not declare a named parameter cannot take one**, and Raku++ was
accepting undeclared nameds silently, so the bare-scalar candidate was winning
calls that thread `:sorted` through to its sibling. Dispatch now rejects an
undeclared named — except where Raku says otherwise: `*%rest`, a `|c` capture,
and methods, which carry an implicit `*%_`.

The second was in the regex engine. A fix to `<?[…]>` — the class-assertion
shorthand — had been applied to the keyword form as well, so `<?before [ … ]>`
read its bracket as a character class instead of a group, and YAMLish's
block-scalar rule stopped parsing. The shorthand applies only to the
keyword-less form; that is now what the engine does.
