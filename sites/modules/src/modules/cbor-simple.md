---
name: CBOR::Simple
version: 0.1.4
auth: zef:japhb
kind: Distribution · data format
summary: A CBOR codec in three subs — encode, decode, and a diagnostic notation
  that prints what the bytes mean, which is the one that makes the format
  learnable.
status: full
suite: 7 files, green
tested: 2026-09-16
license: Artistic-2.0
depends: TinyFloats
raku-land: https://raku.land/zef:japhb/CBOR::Simple
source: https://github.com/japhb/CBOR-Simple.git
---

## What it is for

CBOR is RFC 8949: JSON's data model in binary, with the additions JSON needed
and never got — byte strings that are not base64, integers that do not become
floats, and a tag mechanism for saying "this map is a date". It is what COSE,
WebAuthn and a good deal of embedded messaging are built on.

This distribution is the whole codec in three exported subs, and the third one
is why the page is worth reading.

## Encoding, and what the bytes say

```raku name="cbor"
use CBOR::Simple;

for 42, -1, 1.5e0, 'hi', [1, 2, 3], True, Any -> $v {
    my $b = cbor-encode($v);
    say sprintf('%-12s %-22s %s',
                $v.raku, $b.list».fmt('%02x').join(' '), cbor-diagnostic($b));
}
say '';
my %deep = name => 'raku', revisions => <6.c 6.d 6.e>, stable => True;
my $enc  = cbor-encode(%deep);
my %back = cbor-decode($enc);
say 'a nested round trip: ', $enc.bytes, ' bytes';
say '  keys     ', %back.keys.sort.join(' ');
say '  revisions ', %back<revisions>.join(' ');
say '  stable   ', %back<stable>;
```

```output
42           18 2a                  42
-1           20                     -1
1.5e0        fa 3f c0 00 00         1.5_2
"hi"         62 68 69               "hi"
$[1, 2, 3]   83 01 02 03            [1, 2, 3]
Bool::True   f5                     true
Any          f6                     null

a nested round trip: 42 bytes
  keys     name revisions stable
  revisions 6.c 6.d 6.e
  stable   True
```

`cbor-diagnostic` is the feature. It takes encoded bytes and returns CBOR's
*diagnostic notation* — the human-readable form the RFC uses in its own
examples — so you can check what you produced without a hex editor. `18 2a` is
"the next byte is an unsigned integer", then 42; `20` is the whole of −1,
because small negatives are encoded in the initial byte.

`1.5_2` in the diagnostic output is not a typo. The `_2` is the float width:
CBOR stores this as a 32-bit float, and the notation records which of the three
sizes was chosen. That choice is what `TinyFloats`, the one dependency, is for.

Note also that `Any` encodes to `f6` and comes back as JSON `null`. CBOR has
both `null` and `undefined` (`f7`), and this codec maps the type object to
`null`.

## What it will not encode

```raku fragment
cbor-encode(v6.c)   # Don't know how to encode a Version
```

The codec covers the Raku types with an obvious CBOR image — `Int`, `Num`,
`Rat`, `Str`, `Blob`, `Array`, `Hash`, `Bool`, `Instant`, `DateTime` — and
returns a `Failure` for anything else rather than inventing a tag. That is the
right call, but it means the failure surfaces at the *next* call rather than at
`cbor-encode` itself: an unchecked `cbor-decode(cbor-encode($x))` reports
"cannot resolve caller `cbor-decode(Failure)`", which points at the wrong line.
Check the encode result, or run with `use fatal`.

## Where the two engines differ

Nowhere, for the codec. Every encoding above, every diagnostic string, and the
nested round trip are byte-identical on Raku++ and Rakudo, and all seven test
files pass on both.

One difference is worth knowing because it will bite you while *debugging* this
module rather than using it. `.raku` on a decoded structure does not print the
same text on the two engines:

```raku fragment
say cbor-decode(cbor-encode([1, 2])).raku;
# Rakudo:  $[1, 2]        (the item container is shown)
# Raku++:  [1, 2]
```

The values are the same and compare equal; only the `.raku` rendering of the
item container differs. Compare decoded data with `eqv` or on its contents, not
by round-tripping `.raku` through a string — which is good advice on one engine
and necessary across two.
