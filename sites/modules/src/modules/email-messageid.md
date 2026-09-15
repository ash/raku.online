---
name: Email::MessageID
version: 0.0.1
auth: zef:lizmat
kind: Distribution · email
summary: Generate a value for a Message-ID header from a nanosecond
  timestamp, a short random run and the process id, attached to the machine's
  hostname.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/Email::MessageID
source: https://codeberg.org/lizmat/Email-MessageID.git
---

## What it is for

Every email needs a `Message-ID:` header, and it has to be globally unique
because threading, deduplication and bounce correlation all key on it. RFC
5322 says the right-hand side should be a domain you control and leaves the
left-hand side to you.

This distribution mints one: a timestamp, some randomness and the process id,
joined with dots.

## Minting an identifier

The values are unique by construction, so an example asserts their
**properties**:

```raku name="shape"
use Email::MessageID;

my @ids = (^500).map({ message-id() });

say 'exactly one @ in each   : ', ?all(@ids.map({ .comb('@') == 1 }));
say 'no whitespace           : ', ?all(@ids.map({ !/\s/ }));
say 'no angle brackets       : ', ?all(@ids.map({ !/<[<>]>/ }));
say 'distinct over 500 draws : ', @ids.unique.elems == 500;
say '';
my @f = @ids[0].split('@')[0].split('.');
say 'the local part has ', @f.elems, ' dot-separated fields';
say '  field 1 is a timestamp : ', ?so @f[0] ~~ /^ \d+ $/;
say '  field 2 is hex-ish     : ', ?so @f[1] ~~ /^ <[A..Fa..f0..9]>+ $/;
say '  field 3 is this PID    : ', @f[2] == $*PID;
say '  host part is the hostname : ', @ids[0].split('@')[1] eq $*KERNEL.hostname;
```

```output
exactly one @ in each   : True
no whitespace           : True
no angle brackets       : True
distinct over 500 draws : True

the local part has 3 dot-separated fields
  field 1 is a timestamp : True
  field 2 is hex-ish     : True
  field 3 is this PID    : True
  host part is the hostname : True
```

## Supplying your own halves

```raku name="explicit"
use Email::MessageID;

say 'bare    : ', message-id(:host<example.com>, :user<fixed-key>);
say ':header : ', message-id(:host<example.com>, :user<fixed-key>, :header);
```

```output
bare    : fixed-key@example.com
:header : Message-ID: <fixed-key@example.com>
```

`:header` returns the whole header line, in angle brackets. The bare form
returns `user@host` with **no brackets**, which is not a valid `msg-id` field
value on its own — so use one or the other, never the bare value pasted after
your own `Message-ID: `.

## The one thing to know

The default identifier is not opaque. It publishes your machine's hostname,
your process id, and the exact nanosecond you generated it, in clear text, in
a header that travels with every message you send.

```raku name="disclosure"
use Email::MessageID;

my $id = message-id();
say 'hostname in the identifier : ', $id.split('@')[1] eq $*KERNEL.hostname;
say 'PID in the identifier      : ', $id.split('@')[0].split('.')[2] == $*PID;
say '';
my @stamps = (^200).map({ message-id().split('@')[0].split('.')[0].Int });
say 'the leading field is strictly increasing across 200 draws : ', [<] @stamps;
say '  so a recipient holding two of your messages can order them';
say '  and measure the interval between them';
```

```output
hostname in the identifier : True
PID in the identifier      : True

the leading field is strictly increasing across 200 draws : True
  so a recipient holding two of your messages can order them
  and measure the interval between them
```

The phrase "world unique" invites you to read the value as a random token. It
is not random, it is **structured**, and three of its four components are
facts about your computer. A recipient with two of your messages can order
them and time the gap; a recipient with many can estimate your sending volume
from the PID and timestamp gaps.

Anywhere the identifier will be seen by someone you would not tell your
hostname to, pass an explicit `:host` — a domain you actually control, as RFC
5322 intends — and an explicit `:user`.

## Where the two engines differ

In clock resolution, visibly. The module builds its leading field from the
core `nano` routine, and under Raku++ every value is a multiple of 1000 — so
the timestamps all end in `000` — while Rakudo delivers genuine nanosecond
granularity. Uniqueness held at 500 of 500 in-process and across separate
processes on both engines, so it does not cost you a collision here; it does
mean the identifiers carry less entropy on one engine than the other.

Two smaller notes. The random component is only three to nine characters drawn
from a 22-symbol alphabet, so uniqueness rests mainly on the timestamp and the
PID. And the sub is declared `my sub … is export`, which makes it importable
but never qualifiable: `Email::MessageID::message-id(…)` does not resolve on
either engine.
