---
name: JSON::OptIn
version: 0.0.2
auth: zef:jonathanstowe
kind: Distribution · data format
summary: One empty marker role and the trait that applies it — the shared
  answer to "was this attribute deliberately made JSON-visible", so several
  serialisation modules can agree without depending on each other.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:jonathanstowe/JSON::OptIn
source: https://github.com/jonathanstowe/JSON-OptIn
---

## What it is for

A class with fifteen attributes usually wants three of them on the wire.
Marking those three is easy; the hard part is that the marshaller, the
unmarshaller and the renaming trait are three separate distributions, and
they need to agree on what the mark *is* without any of them depending on
the others.

The answer is a fourth distribution that contains nothing but the mark.
Thirteen lines: an empty role, and a trait that applies it. Everything
policy-shaped lives in the modules that consult it.

## The mark

```raku name="mark"
use JSON::OptIn;
use JSON::Class;
use JSON::Marshal;

class Account does JSON::Class {
    has Str $.user is json;
    has Int $.id   is json;
    has Str $.token;
}

for Account.^attributes -> $a {
    say $a.name, ' marked: ', ($a ~~ JSON::OptIn::OptedInAttribute).Str;
}

my $a = Account.new(user => 'ada', id => 7, token => 'secret');
say marshal($a, :!pretty, :sorted-keys);
say marshal($a, :!pretty, :sorted-keys, :opt-in);
say JSON::OptIn::OptedInAttribute.^methods(:local).elems;
```

```output
$!user marked: True
$!id marked: True
$!token marked: False
{"id":7,"token":"secret","user":"ada"}
{"id":7,"user":"ada"}
0
```

The role is genuinely empty — no methods, no state, nothing to configure.
It exists to be asked about. On its own the mark does nothing observable,
which the third-from-last line shows: an ordinary `marshal` publishes
everything regardless. Only `:opt-in` consults it, and then the token stays
home.

## The one thing to know

`is json(False)` opts the attribute **in**:

```raku name="no-off-switch"
use JSON::OptIn;
use JSON::Class;
use JSON::Marshal;

class Record does JSON::Class {
    has Str $.keep is json;
    has Str $.no   is json(False);
    has Str $.bare;
}

for Record.^attributes -> $a {
    say $a.name, ' -> ', ($a ~~ JSON::OptIn::OptedInAttribute).Str;
}
say marshal(Record.new(keep => 'k', no => 'n', bare => 'b'),
            :!pretty, :sorted-keys, :opt-in);
```

```output
$!keep -> True
$!no -> True
$!bare -> False
{"keep":"k","no":"n"}
```

The trait's argument is required by the signature and then never read: the
body applies the role unconditionally. So the trait has no off position,
and `is json(False)`, `is json(0)` and `is json(Nil)` all read as attempts
to say "not this one" that mean the opposite. The only way to leave an
attribute out is to write no trait at all.

That matters more than it looks, because three other traits in the family
apply this same role as a side effect — `is json-name`, `is
json-skip-null`, and the `is marshalled-by` converters. An attribute can
therefore be opted in without the word `json` appearing anywhere on it,
and a class that uses `:opt-in` alongside a rename publishes a set nobody
chose. Mark the set explicitly and check it with the loop above.

One last thing: `is json` is an attribute trait only. Written on a class it
fails with an inheritance error rather than an unknown-trait one, because
`is Something` is also how a superclass is declared.
