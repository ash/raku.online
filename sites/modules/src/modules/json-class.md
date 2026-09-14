---
name: JSON::Class
version: 0.0.21
auth: zef:jonathanstowe
kind: Distribution · data format
summary: A role that gives any class a `to-json` and a `from-json` — public
  attributes out, typed objects back in, nested classes and typed arrays
  included — built on JSON::Marshal and JSON::Unmarshal.
status: full
suite: 6 files, green
tested: 2026-09-14
license: Artistic-2.0
depends: JSON::Marshal, JSON::Unmarshal, JSON::OptIn, JSON::Name
raku-land: https://raku.land/zef:jonathanstowe/JSON::Class
source: https://github.com/jonathanstowe/JSON-Class
---

## What it is for

`JSON::Fast` turns JSON into hashes and arrays, and for a configuration file
that is exactly right. For a record with a known shape it is one step short:
you wanted a `Person` with an `Int` birth year and an `Address` inside it, not
a hash you check the keys of by hand. This role closes the gap. Compose it
into a class and the class gains `to-json`, which walks the public attributes,
and `from-json`, which reads a document into a new instance — recursing into
attributes whose types are themselves classes, and refusing values that do
not fit the declared type.

The two directions are separate distributions (`JSON::Marshal` and
`JSON::Unmarshal`) and this one is the thirty-line role that puts both on a
class; sixteen other distributions build on it, `META6` among them.

## In and out

```raku name="round-trip"
use JSON::Class;

class Address does JSON::Class { has Str $.city; has Str $.country }
class Person does JSON::Class {
    has Str     $.name;
    has Int     $.born;
    has Address $.address;
    has Str     @.tags;
    has Bool    $.active = True;
    has Str     $!secret = 'not yours';
}

my $ada = Person.new(name => 'Ada', born => 1815, tags => <maths engines>,
                     address => Address.new(city => 'London', country => 'UK'));
say $ada.to-json(:!pretty, :sorted-keys);

my $grace = Person.from-json('{"name":"Grace","born":1906,"tags":["compilers"],'
                           ~ '"address":{"city":"New York","country":"US"}}');
say $grace.address.city, ', ', $grace.address.^name, ', born ', $grace.born + 0;
say $grace.active;
```

```output
{"active":true,"address":{"city":"London","country":"UK"},"born":1815,"name":"Ada","tags":["maths","engines"]}
New York, Address, born 1906
True
```

Only attributes with accessors travel — `$!secret` is in neither direction —
and a default fills in for anything the document leaves out, which is how
`$grace.active` is `True`. A key the class does not declare is ignored on the
way in; a value of the wrong type (`"born": "not a number"`) throws
`JSON::Unmarshal::X::CannotUnmarshal`, naming the attribute.

A document that is a list of records has a shape too, and the role covers it
with one idiom: parameterise `Array` with the class and mix the role into the
result.

```raku name="typed-array"
use JSON::Class;

class Person does JSON::Class { has Str $.name; has Int $.born }
constant People = (Array[Person] but JSON::Class);

my $many = People.from-json('[{"name":"Ada","born":1815},{"name":"Grace","born":1906}]');
say $many.elems, ' ', $many[0].^name, ' ', $many.map(*.name).join(' & ');
say $many.to-json(:!pretty, :sorted-keys);
```

```output
2 Person Ada & Grace
[{"born":1815,"name":"Ada"},{"born":1906,"name":"Grace"}]
```

Under the Raku++ 3.28.0 release this second form came back as an array of
plain hashes, because the mixed type answered `Mu` when asked what its
elements were. The engine has been fixed since, and the example runs on both
engines like every other one here.

## The one thing to know

Pass `:sorted-keys`, or the order of the keys is whatever the hash gives you.
`to-json` walks a hash of the attributes, and Rakudo randomises hash order
per process — so the same object serialises differently on two runs, which is
harmless for a consumer and a nuisance for a test, a diff or a content hash.
The examples above sort for exactly that reason.

Two smaller defaults to know before relying on the output: `to-json` is
pretty-printed unless you say `:!pretty`, and an attribute that holds no value
is written as `null` rather than left out — `:skip-null` drops it. And if a
class has attributes that must never reach the wire, `does JSON::Class[:opt-in]`
flips the rule so that only the ones marked `is json` are serialised.
