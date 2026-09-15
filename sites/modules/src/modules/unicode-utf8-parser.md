---
name: Unicode::UTF8-Parser
version: 0.3
auth: zef:raku-community-modules
kind: Distribution · encoding
summary: Turn a reactive stream of UTF-8 bytes into a stream of characters,
  holding partial multi-byte sequences across emissions.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Unicode::UTF8-Parser
source: https://github.com/raku-community-modules/Unicode-UTF8-parser.git
---

## What it is for

`Buf.decode('utf8')` needs the whole buffer. A socket does not give you the
whole buffer — it gives you whatever arrived, which may end in the middle of a
three-byte character, and the next read supplies the rest.

This distribution is the streaming decoder for that case: bytes in on a
`Supply`, characters out on a `Supply`, with the partial sequence held across
the boundary.

## Decoding a stream

```raku name="decode"
use Unicode::UTF8-Parser;

sub decode(@bytes) {
    my $supplier = Supplier.new;
    my @out;
    parse-utf8-bytes($supplier.Supply).tap(-> $c { @out.push($c) });
    $supplier.emit($_) for @bytes;
    $supplier.done;
    @out
}

say 'ASCII "Hi"          : ', decode([0x48, 0x69]).raku;
say 'two bytes, U+00E9   : ', decode([0xC3, 0xA9]).raku;
say 'three bytes, U+4E2D : ', decode([0xE4, 0xB8, 0xAD]).raku;
say 'four bytes, U+1F600 : ', decode([0xF0, 0x9F, 0x98, 0x80]).raku;
```

```output
ASCII "Hi"          : ["H", "i"]
two bytes, U+00E9   : ["é"]
three bytes, U+4E2D : ["中"]
four bytes, U+1F600 : ["😀"]
```

Note the input. The `Supply` must emit **one `Int` per byte** — not a `Buf`
per chunk, which is what `IO::Socket::Async` actually gives you. Hand it a
`Buf` and you get nonsense on one engine and a quit on the other; see the last
section.

## Sequences split across emissions

```raku name="split"
use Unicode::UTF8-Parser;

sub decode(@chunks) {
    my $supplier = Supplier.new;
    my @out;
    parse-utf8-bytes($supplier.Supply).tap(-> $c { @out.push($c) });
    for @chunks -> @chunk { $supplier.emit($_) for @chunk }
    $supplier.done;
    @out
}

say 'U+4E2D all at once   : ', decode([[0xE4, 0xB8, 0xAD],]).raku;
say 'the same, one byte at a time : ', decode([[0xE4], [0xB8], [0xAD]]).raku;
say 'and mixed with ASCII : ', decode([[0x48], [0xE4, 0xB8], [0xAD], [0x69]]).raku;
```

```output
U+4E2D all at once   : ["中"]
the same, one byte at a time : ["中"]
and mixed with ASCII : ["H", "中", "i"]
```

That is the whole point of the distribution, and it works: the partial
sequence survives the boundary and the character arrives whole.

## The one thing to know

It is a decoder wearing a parser's name. It accepts overlong encodings and
surrogates that every UTF-8 validator must reject.

```raku name="permissive-trap"
use Unicode::UTF8-Parser;

sub decode(@bytes) {
    my $supplier = Supplier.new;
    my @out;
    parse-utf8-bytes($supplier.Supply).tap(-> $c { @out.push($c) });
    $supplier.emit($_) for @bytes;
    $supplier.done;
    @out
}

say 'C0 80    — an overlong U+0000 : ', decode([0xC0, 0x80]).map({ .ords }).raku;
say 'E0 80 AF — an overlong "/"    : ', decode([0xE0, 0x80, 0xAF]).map({ .ords }).raku;
say 'ED A0 80 — a surrogate        : ', decode([0xED, 0xA0, 0x80]).map({ .ords }).raku;
say '';
say 'for comparison, Raku\'s own decoder on the same bytes:';
for [0xC0, 0x80], [0xE0, 0x80, 0xAF], [0xED, 0xA0, 0x80] -> @b {
    my $r = try Buf.new(@b).decode('utf8');
    say sprintf('  %-12s -> %s', @b.map({ .fmt('%02X') }).join(' '),
        $! ?? 'rejected' !! 'accepted');
}
```

```output
C0 80    — an overlong U+0000 : ((0,).Seq,).Seq
E0 80 AF — an overlong "/"    : ((47,).Seq,).Seq
ED A0 80 — a surrogate        : ((55296,).Seq,).Seq

for comparison, Raku's own decoder on the same bytes:
  C0 80        -> rejected
  E0 80 AF     -> rejected
  ED A0 80     -> rejected
```

`E0 80 AF` decoding to `/` is the textbook overlong-slash path-traversal
bypass, and Raku's own decoder rejects all three.

Do not use this to validate untrusted input. Decode with it if you must
stream, then re-encode and compare, or validate separately.

Two more hazards in the same area. The output `Supply` is **heterogeneously
typed** — `Str` for decoded characters, bare `Int` for bytes it could not
decode — so a `-> Str $c` tap signature fails on malformed input. And a
truncated sequence at end of stream is **dropped silently**, with no `quit`
and no marker.

## Where the two engines differ

On what happens when you hand it the obvious wrong input.

`IO::Socket::Async` emits `Buf` chunks, so that is what everyone tries first.
Under Rakudo the supply **quits** with `No such method 'chr' for invocant of
type 'Buf'`, which is an unmistakable signal. Under Raku++ it returns
`chr` of the byte **count** — plausible-looking single characters that are
pure garbage, with no error at all.

So the same mistake is loud on one engine and silent on the other. Flatten
your chunks into individual `Int`s, as every example on this page does.

One thing that is the same on both: a codepoint above U+10FFFF **quits the
whole supply** rather than substituting a replacement character, killing the
stream.
