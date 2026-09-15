---
name: IDNA::Punycode
version: 1.0.1
auth: zef:raku-community-modules
kind: Distribution · encoding
summary: The bootstring encoding behind internationalised domain names —
  one sub each way, turning Unicode text into an `xn--` label and back.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:raku-community-modules/IDNA::Punycode
source: https://github.com/raku-community-modules/IDNA-Punycode
---

## What it is for

The domain name system carries ASCII. A domain written in Greek, Japanese or
German with an umlaut therefore travels as an ASCII transcription, and the
transcription is Punycode: a bootstring encoding that packs the non-ASCII
characters into a suffix and marks the result with `xn--`. Browsers do this
in both directions every time someone types such a name, and any program
that resolves, stores or compares one has to do it too.

This distribution is the algorithm, RFC 3492, as two subs.

## Both directions

```raku name="encode-decode"
use IDNA::Punycode;

for <münchen bücher ελλάς 日本語 россия> -> $label {
    my $encoded = encode_punycode($label);
    say $label, ' -> ', $encoded, ' -> ', decode_punycode($encoded);
}

say encode_punycode('example');
say decode_punycode('plain');
```

```output
münchen -> xn--mnchen-3ya -> münchen
bücher -> xn--bcher-kva -> bücher
ελλάς -> xn--hxarsa0b -> ελλάς
日本語 -> xn--wgv71a119e -> 日本語
россия -> xn--h1alffa9f -> россия
example
plain
```

Text that is already ASCII comes back unchanged and unprefixed, which is
what the standard asks for: a label only becomes `xn--` something when it
has to. The names use underscores rather than the hyphens modern Raku
prefers, which is worth knowing when you go looking for them.

## The one thing to know

It encodes a **label**, and it will not stop you handing it a whole domain
name. The dot is just another character to the algorithm, so what comes back
is a single label with a dot inside it — which no resolver will accept, and
which does not even survive a round trip through this module's own decoder:

```raku name="whole-domain"
use IDNA::Punycode;

say encode_punycode('münchen.de');
say decode_punycode(encode_punycode('münchen.de'));
say 'münchen.de'.split('.').map({ encode_punycode($_) }).join('.');
say decode_punycode('XN--MNCHEN-3YA');
```

```output
xn--mnchen.de-q9a
münchen.de
xn--mnchen-3ya.de
XN--MNCHEN-3YA
```

The round trip survives, which is exactly what makes this quiet: the first
line is a well-formed Punycode string that decodes back to what you gave it,
and it is still not a domain name, because a label may not contain a dot.
The third line is the correct answer, and getting it is your job: split on
the dot, encode each label, join them back. The fourth line is the other
trap. Domain names are case-insensitive, the `xn--` test in this module is
not, and an upper-case prefix is returned unchanged rather than decoded —
silently, because a decode that finds no prefix is defined as a no-op.
Lower-case before decoding, and treat "came back the same" as "was not
encoded", never as "decoded successfully".

There is no length check either. Sixty accented characters encode to a
sixty-six character label, past the sixty-three octet limit the domain name
system imposes, with no complaint from here.
