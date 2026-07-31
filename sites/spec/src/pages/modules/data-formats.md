---
title: Data formats — JSON & YAML
slug: data-formats
status: full
browser: false
browser-why: needs installed module distributions
rakulib: battery
order: 20
summary: JSON::Fast, JSON::Tiny and YAMLish under Raku++ — parsing, generating, round-tripping.
---

The everyday serialization modules work unmodified. Every example below runs
under Raku++ with the pinned module sources; the output shown is verified against
both the interpreter and Rakudo at build time.

## JSON::Fast

The de-facto standard JSON module. `from-json` gives you plain hashes and
arrays; `to-json` goes the other way (`:sorted-keys` makes output
deterministic, `:!pretty` keeps it on one line).

```raku
use JSON::Fast;

my $config = from-json(q:to/END/);
    { "server": { "port": 8080, "tls": false },
      "backends": ["alpha", "beta"] }
    END

say $config<server><port>;
say $config<backends>.join(', ');
say to-json({ ok => True, n => 42 }, :sorted-keys, :!pretty);
```
```output
8080
alpha, beta
{"n":42,"ok":true}
```

## JSON::Tiny

The lighter alternative — a grammar-driven parser in a few hundred lines.
Both directions work: `from-json` parses with a real Raku grammar, and
`to-json` \u-escapes anything outside printable ASCII, exactly like Rakudo.

```raku
use JSON::Tiny;

my $parsed = from-json('{"name": "raku", "level": [1, 2.5, true]}');
say $parsed<name>;
say $parsed<level>[1];
say to-json(["four", "héllo"]);
```
```output
raku
2.5
[ "four", "h\u00e9llo" ]
```

## YAMLish

YAML in pure Raku. `load-yaml` parses one document; `save-yaml` emits one.

```raku
use YAMLish;

my $doc = load-yaml(q:to/END/);
    name: rakupp
    langs:
      - Raku
      - C++
    END

say $doc<name>;
say $doc<langs>.elems;
```
```output
rakupp
2
```
