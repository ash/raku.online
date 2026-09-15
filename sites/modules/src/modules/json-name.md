---
name: JSON::Name
version: 0.0.7
auth: zef:jonathanstowe
kind: Distribution · data format
summary: One attribute trait that records a different JSON key for an
  attribute — for the `@type` and `created_at` spellings a Raku identifier
  cannot have.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: JSON::OptIn
raku-land: https://raku.land/zef:jonathanstowe/JSON::Name
source: https://github.com/jonathanstowe/JSON-Name
---

## What it is for

The JSON you have to consume was not designed around Raku's identifier
rules. Its keys are `@type`, `created_at`, `Content-Type`, `666.evil.name`
— none of which can be an attribute name, and some of which no language
would accept. The mapping has to live somewhere, and the natural place is
on the attribute itself.

This distribution is that one trait, and nothing else: a place for
`JSON::Marshal` and `JSON::Unmarshal` to look when the key and the
attribute have different names. Seven distributions depend on it.

## Renaming an attribute

```raku name="rename"
use JSON::Name;
use JSON::Class;
use JSON::Marshal;
use JSON::Unmarshal;

class Event does JSON::Class {
    has Str $.kind   is json-name('@type');
    has Int $.at     is json-name('666.evil.name');
    has Str $.plain;
}

my $e = Event.new(kind => 'ping', at => 42, plain => 'ordinary');
say marshal($e, :!pretty, :sorted-keys);

my $back = unmarshal('{"@type":"pong","666.evil.name":7,"plain":"p"}', Event);
say $back.kind, ' ', $back.at, ' ', $back.plain;

for Event.^attributes -> $a {
    say $a.name, ' -> ',
        ($a ~~ JSON::Name::NamedAttribute ?? $a.json-name !! '(same)');
}
```

```output
{"666.evil.name":42,"@type":"ping","plain":"ordinary"}
pong 7 p
$!kind -> @type
$!at -> 666.evil.name
$!plain -> (same)
```

The trait mixes a role into the attribute's meta-object carrying the
replacement name, and the two serialisers consult it. Nothing else changes:
the Raku side keeps its ordinary name and the wire side keeps its awkward
one.

## The one thing to know

Renaming an attribute also opts it in to selective marshalling, which is a
separate feature you did not ask for:

```raku name="opt-in"
use JSON::Name;
use JSON::Class;
use JSON::Marshal;
use JSON::OptIn;

class Record does JSON::Class {
    has Str $.renamed is json-name('R');
    has Str $.ordinary;
}

for Record.^attributes -> $a {
    say $a.name, ' opted in: ', ($a ~~ JSON::OptIn::OptedInAttribute).Str;
}

my $r = Record.new(renamed => 'one', ordinary => 'two');
say marshal($r, :!pretty, :sorted-keys);
say marshal($r, :!pretty, :sorted-keys, :opt-in);
```

```output
$!renamed opted in: True
$!ordinary opted in: False
{"R":"one","ordinary":"two"}
{"R":"one"}
```

`NamedAttribute` composes the opt-in marker role, so an attribute you
renamed for purely cosmetic reasons is now one of the few that survive
`:opt-in` — and the attribute you did nothing to is the one that vanishes.
That is the opposite of what the `:opt-in` mode is for, which is to publish
only the fields you explicitly listed.

If you use `:opt-in`, mark every attribute you mean to publish with `is
json` explicitly and do not let the rename do it implicitly. The same
implicit opt-in comes from `is json-skip-null` and from the
`is marshalled-by` converters, so the word `json` need not appear on an
attribute for it to be in the set.

Two smaller things: two attributes may be given the same JSON name with no
complaint, and one of them then wins on the way out while both are filled
from the same key on the way in. And Raku++ currently accepts a non-string
argument to the trait where Rakudo rejects it at compile time, so pass a
string literal.
