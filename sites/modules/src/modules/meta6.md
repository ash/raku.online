---
name: META6
version: 0.0.31
auth: zef:jonathanstowe
kind: Distribution · data format
summary: A distribution's META6.json as a typed object — name, version,
  provides, the four kinds of dependency — read from a string or a file and
  written back out, with every field the specification names as a method.
status: full
suite: 9 files, green
tested: 2026-09-14
license: Artistic-2.0
depends: JSON::Class, JSON::Name
raku-land: https://raku.land/zef:jonathanstowe/META6
source: https://github.com/jonathanstowe/META6
---

## What it is for

Every distribution carries a `META6.json`, and every tool that works on
distributions — an installer, a linter, a release script, the test that
checks the file is sane — starts by reading it. Reading it with a JSON parser
gives a hash with whatever keys happened to be there; reading it with this
distribution gives an object whose methods are the fields the specification
defines, with `version` already a `Version`, the dependency lists already
lists, and the unknown keys where they belong.

It is `JSON::Class` applied to one document type — the class declares an
attribute per field, and the role does the reading and writing. `Test::META`
is the best-known thing built on it; eight distributions depend on it.

## Reading one

```raku name="read"
use META6;

my $json = q:to/JSON/;
    { "name": "Widget::Tools", "version": "1.2.3", "auth": "zef:someone",
      "description": "Tools for widgets", "raku": "6.d", "license": "Artistic-2.0",
      "authors": ["A. Person"],
      "provides": { "Widget::Tools": "lib/Widget/Tools.rakumod" },
      "depends": ["JSON::Fast", "URI:ver<0.3+>"], "test-depends": ["Test::META"],
      "source-url": "https://example.org/widget-tools.git" }
    JSON

my $m = META6.new(:$json);
say $m.name, ' ', $m.version, ' (', $m.version.^name, ')';
say $m.raku-version, ' ', $m.license;
say $m.depends.join(', ');
say $m.test-depends.join(', ');
say $m.provides.keys.join(', ');
say $m<auth>;
say META6.new(json => $m.to-json).name;
```

```output
Widget::Tools v1.2.3 (Version)
v6.d Artistic-2.0
JSON::Fast, URI:ver<0.3+>
Test::META
Widget::Tools
zef:someone
Widget::Tools
```

`new(:$json)` reads a string and `new(file => 'META6.json')` a file; the
object also answers hash subscripts (`$m<auth>`) for the times a field name
is in a variable. `to-json` writes it back, and the last line shows that a
document survives the round trip — a release script can read, bump
`version`, and write.

## The one thing to know

The dependency fields keep the shape the file used, and the specification
allows two. `"depends": ["A", "B"]` comes back as a list of strings, as
above; the phase form, `"depends": { "runtime": { "requires": ["A"] } }`,
comes back as that nested hash. `.depends` does not flatten one into the
other, so a tool that walks dependencies has to accept both shapes — which
the ecosystem's own installers do, and which a quick script tends to forget
on the second one it meets.

One more field to read carefully: the language version is taken from the
`raku` key, as the current specification spells it. A file that still says
`"perl": "6.d"` — and many older ones do — leaves `raku-version` undefined
rather than being read under the old name, and `meta-version` defaults to
`v0` when the key is absent, as it is in most files in the wild.
