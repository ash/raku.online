---
name: Netstring
version: 0.0.4
auth: zef:raku-community-modules
kind: Distribution · encoding
summary: Bernstein's netstring framing — a decimal byte count, a colon, the
  payload, a comma — as two encoders and one socket reader.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Netstring
source: https://github.com/raku-community-modules/Netstring.git
---

## What it is for

A stream protocol has to say where one message ends and the next begins.
Scanning for a delimiter means escaping it in the payload; a netstring instead
declares the length up front — `5:hello,` — so the reader knows exactly how
many bytes to take and the payload needs no escaping at all.

That property is why netstrings turn up in supervision protocols, in
`qmail`-lineage tooling, and anywhere two processes talk over a pipe.

## Framing a message

```raku name="frame"
use Netstring;

for 'hello', '', 'a', 'x' x 12 -> $s {
    say sprintf('to-netstring(%-14s) = %s', $s.raku, to-netstring($s).raku);
}
say '';
my $u = 'caf' ~ "\c[LATIN SMALL LETTER E WITH ACUTE]";
say 'the prefix is a BYTE count, not a character count:';
say '  input          : ', $u.raku;
say '  .chars         : ', $u.chars;
say '  utf8 bytes     : ', $u.encode('utf8').bytes;
say '  to-netstring   : ', to-netstring($u).raku;
```

```output
to-netstring("hello"       ) = "5:hello,"
to-netstring(""            ) = "0:,"
to-netstring("a"           ) = "1:a,"
to-netstring("xxxxxxxxxxxx") = "12:xxxxxxxxxxxx,"

the prefix is a BYTE count, not a character count:
  input          : "café"
  .chars         : 4
  utf8 bytes     : 5
  to-netstring   : "5:café,"
```

Four characters, five bytes, and the frame says 5 — which is correct, and
which a length-prefixed format has to get right.

## Bytes out

```raku name="buf"
use Netstring;

sub hex($b) { $b.list.map({ .fmt('%02X') }).join(' ') }

my $u = 'caf' ~ "\c[LATIN SMALL LETTER E WITH ACUTE]";
say 'to-netstring-buf : ', hex(to-netstring-buf($u));
say '';
my $binary = Blob.new(0x00, 0x01, 0xFF, 0xFE, 0x80);
say 'a blob that is not valid UTF-8:';
say '  bytes            : ', hex($binary);
say '  to-netstring-buf : ', hex(to-netstring-buf($binary));
```

```output
to-netstring-buf : 35 3A 63 61 66 C3 A9 2C

a blob that is not valid UTF-8:
  bytes            : 00 01 FF FE 80
  to-netstring-buf : 35 3A 00 01 FF FE 80 2C
```

Which is the thing to know.

## The one thing to know

`to-netstring` has a `Blob:D` candidate that cannot carry binary data — the
one job netstrings exist for.

```raku name="blob-trap"
use Netstring;

my $binary = Blob.new(0x00, 0x01, 0xFF, 0xFE, 0x80);

say 'to-netstring-buf handles it : ',
    to-netstring-buf($binary).list.map({ .fmt('%02X') }).join(' ');
say '';
my $r = try to-netstring($binary);
say 'to-netstring on the same blob : ', $! ?? 'threw' !! $r.raku;
say '';
say 'the Str-returning candidate UTF-8 DECODES the payload to build';
say 'its return value, so any blob that is not valid UTF-8 fails.';
say 'always use to-netstring-buf for bytes.';
```

```output
to-netstring-buf handles it : 35 3A 00 01 FF FE 80 2C

to-netstring on the same blob : threw

the Str-returning candidate UTF-8 DECODES the payload to build
its return value, so any blob that is not valid UTF-8 fails.
always use to-netstring-buf for bytes.
```

Both candidates advertise a `Blob:D` signature and only one means it. Worse,
it fails **late** — on whichever blob first contains a byte sequence that is
not valid UTF-8 — so it passes every test written against ASCII fixtures and
breaks in production on the first binary payload.

## Where the two engines differ

`read-netstring` is completely dead under Rakudo.

The reader drives a native-integer accumulator loop — `my int $byte; until
($byte = $in.read(1)[0]) == 58 {…}` — which Rakudo rejects with `This
container does not reference a native integer` on the very first byte read, for
valid and invalid input alike. Under Raku++ it works properly: one byte at a
time for the length prefix, one bulk read for the payload, one byte for the
terminator, with clear errors on malformation.

```raku name="reader"
use Netstring;

class FakeSocket does IO::Socket {
    has Buf $.data;
    has Int $.pos is rw = 0;
    method read($n) {
        my $take = min $n.Int, $!data.elems - $!pos;
        my $out = Buf.new($!data[$!pos ..^ $!pos + $take]);
        $!pos += $take;
        $out
    }
}
sub sock(Str $s) { FakeSocket.new(data => Buf.new($s.encode('latin-1').list)) }

# malformed input is refused on both engines, so this much is portable
for 'bad terminator', '5:hello;',
    'non-digit length', 'x:hello,',
    'no colon', '5hello,',
    'empty stream', '' -> $label, $wire {
    my $r = try read-netstring(sock($wire));
    say sprintf('%-18s %-12s -> %s', $label, $wire.raku, $! ?? 'refused' !! 'accepted');
}
```

```output
bad terminator     "5:hello;"   -> refused
non-digit length   "x:hello,"   -> refused
no colon           "5hello,"    -> refused
empty stream       ""           -> refused
```

Refusing malformed input is the only part of the reader that behaves the same
on both engines, which is why that is all the example asserts. Hand it
`5:hello,` and Raku++ returns `hello` while Rakudo throws.

Two further notes, both Raku++ only since that is the only engine where the
reader runs. Leading zeros in the length prefix are accepted (`05:hello,`
works). And a **truncated** stream returns the short content it managed to
read alongside a confusing terminator message, so a caller who ignores the
exception gets silently truncated data.
