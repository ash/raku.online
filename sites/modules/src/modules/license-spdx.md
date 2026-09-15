---
name: License::SPDX
version: 3.28.0
auth: zef:jonathanstowe
kind: Distribution · metadata
summary: The SPDX licence list as a bundled data table, looked up by
  identifier or walked in full, with each licence an object carrying its name,
  approval flags and reference URLs.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: JSON::Class
raku-land: https://raku.land/zef:jonathanstowe/License::SPDX
source: https://github.com/jonathanstowe/License-SPDX.git
---

## What it is for

`"license": "Artistic-2.0"` in a `META6.json` is an SPDX identifier, and so is
the licence field in almost every package format now in use. Validating one,
or turning it into a human-readable name, means having the list.

This distribution ships the list. Everything is local — no network, no
ecosystem index — and the version of the list is itself readable, so you can
tell how current your copy is.

## Looking a licence up

```raku name="lookup"
use License::SPDX;

my $spdx = License::SPDX.new;

say 'list version : ', $spdx.license-list-version;
say 'release date : ', $spdx.release-date;
say 'licences     : ', $spdx.license-ids.elems;
say '';

for <MIT Apache-2.0 Artistic-2.0> -> $id {
    my $l = $spdx.get-license($id);
    say $l.license-id;
    say '  name       : ', $l.name;
    say '  osi        : ', $l.is-osi-approved;
    say '  fsf-libre  : ', $l.is-fsf-libre;
    say '  deprecated : ', $l.is-deprecated-license;
    say '  reference  : ', $l.reference;
}
```

```output
list version : 3.28.0
release date : 2026-02-20
licences     : 727

MIT
  name       : MIT License
  osi        : True
  fsf-libre  : True
  deprecated : False
  reference  : https://spdx.org/licenses/MIT.html
Apache-2.0
  name       : Apache License 2.0
  osi        : True
  fsf-libre  : True
  deprecated : False
  reference  : https://spdx.org/licenses/Apache-2.0.html
Artistic-2.0
  name       : Artistic License 2.0
  osi        : True
  fsf-libre  : True
  deprecated : False
  reference  : https://spdx.org/licenses/Artistic-2.0.html
```

`.licenses` gives you every entry, `.license-ids` just the identifiers, and
`.license-by-id` the underlying hash.

## Deprecated identifiers

```raku name="deprecated"
use License::SPDX;

my $spdx = License::SPDX.new;

for <GPL-3.0 GPL-3.0-only LGPL-2.1 LGPL-2.1-only> -> $id {
    my $l = $spdx.get-license($id);
    say sprintf('%-16s deprecated=%-5s  name=%s', $id, $l.is-deprecated-license, $l.name);
}
say '';
say 'deprecated ids still resolvable : ',
    $spdx.licenses.grep(*.is-deprecated-license).elems, ' of ', $spdx.licenses.elems;
```

```output
GPL-3.0          deprecated=True   name=GNU General Public License v3.0 only
GPL-3.0-only     deprecated=False  name=GNU General Public License v3.0 only
LGPL-2.1         deprecated=True   name=GNU Lesser General Public License v2.1 only
LGPL-2.1-only    deprecated=False  name=GNU Lesser General Public License v2.1 only

deprecated ids still resolvable : 32 of 727
```

Note `GPL-3.0` and `GPL-3.0-only` carry the identical `.name`. The name is not
a unique key; the identifier is. Thirty-two of the entries are deprecated
spellings that still resolve perfectly happily, so a lookup succeeding does
not mean the identifier is one you should be writing.

## The one thing to know

A miss returns a **typed undefined object**, not a failure — so the blow-up
happens later, at the first accessor, far from the lookup.

```raku name="miss-trap"
use License::SPDX;

my $spdx = License::SPDX.new;

for 'Definitely-Not-A-Licence-1.0', 'mit', 'MIT' -> $id {
    my $l = $spdx.get-license($id);
    say "lookup '$id'";
    say '  type    : ', $l.^name;
    say '  defined : ', $l.defined;
    say '  Bool    : ', ?$l;
    say '  isa License : ', $l ~~ License::SPDX::License;
    say '  .license-id : ', (try $l.license-id) // 'threw';
}
```

```output
lookup 'Definitely-Not-A-Licence-1.0'
  type    : License::SPDX::License
  defined : False
  Bool    : False
  isa License : True
  .license-id : threw
lookup 'mit'
  type    : License::SPDX::License
  defined : False
  Bool    : False
  isa License : True
  .license-id : threw
lookup 'MIT'
  type    : License::SPDX::License
  defined : True
  Bool    : True
  isa License : True
  .license-id : MIT
```

A failed lookup gives back something whose `.^name` is
`License::SPDX::License` and which passes a `~~` type check. Only `.defined`
— or `with` or `//` — separates a hit from a miss. Note also that `'mit'` is a
miss: lookups are **case-sensitive**, and SPDX identifiers are conventionally
mixed case.

Test `.defined` immediately, or write `with $spdx.get-license($id) -> $l {…}`.

## Where the two engines differ

In one exception message and one introspection list, neither of which affects
a working program.

The type-object accessor error reads `Cannot look up attributes in a
License::SPDX::License type object` on Raku++ and adds ` Did you forget a
'.new'?` on Rakudo. And Rakudo's `.^methods(:local)` on
`License::SPDX::License` lists an internal `POPULATE` method that Raku++'s
does not, so method-list introspection is not portable between the engines.

Everything else — the list version, the release date, the 727 identifiers,
every flag on every licence tested, and the case sensitivity — was
byte-identical.
