---
name: Compress::LZString
version: 0.0.1
auth: zef:bduggan
kind: Distribution · compression
summary: A pure-Raku port of the JavaScript lz-string dictionary coder, with
  five transport encodings of the same bit stream.
status: full
suite: 3 files, green
tested: 2026-09-15
license: MIT
depends: none beyond the core
raku-land: https://raku.land/zef:bduggan/Compress::LZString
source: git://github.com/bduggan/raku-compress-lzstring.git
---

## What it is for

Browser code that stows a blob in `localStorage` or a query parameter very
often puts it through lz-string, because that library is small, has no
dependencies and produces something URL-safe. If your Raku server has to read
what the browser wrote, or write what the browser will read, you need the same
coder.

Interoperability is the point here, not compression ratio.

## Round trips

```raku name="roundtrip"
use Compress::LZString;

my $text = 'the rain in spain falls mainly on the plain; ' x 6;
say 'input : ', $text.chars, ' chars';
say '';

my $raw = lz-compress($text);
say 'lz-compress        : ', $raw.elems, ' 16-bit units, ', $raw.bytes, ' bytes';
say '  round trip       : ', lz-decompress($raw) eq $text;

my $bytes = lz-compress-bytes($text);
say 'lz-compress-bytes  : ', $bytes.bytes, ' bytes';
say '  round trip       : ', lz-decompress-bytes($bytes) eq $text;

my $b64 = lz-compress-base64($text);
say 'lz-compress-base64 : ', $b64.chars, ' chars';
say '  round trip       : ', lz-decompress-base64($b64) eq $text;

my $uri = lz-compress-uri($text);
say 'lz-compress-uri    : ', $uri.chars, ' chars';
say '  round trip       : ', lz-decompress-uri($uri) eq $text;

my $u16 = lz-compress-utf16($text);
say 'lz-compress-utf16  : ', $u16.elems, ' code points';
say '  round trip       : ', lz-decompress-utf16($u16) eq $text;
```

```output
input : 270 chars

lz-compress        : 53 16-bit units, 106 bytes
  round trip       : True
lz-compress-bytes  : 106 bytes
  round trip       : True
lz-compress-base64 : 144 chars
  round trip       : True
lz-compress-uri    : 142 chars
  round trip       : True
lz-compress-utf16  : 58 code points
  round trip       : True
```

All five are exact, and the compressed values are byte-for-byte the same as
the JavaScript library produces for the same input — which is what makes this
usable across the wire.

## When it is worth using

```raku name="growth"
use Compress::LZString;

for '', 'a', 'ab', 'hello', 'hello world',
    'the quick brown fox ' x 10 -> $s {
    my $u = lz-compress-uri($s);
    say sprintf('%-6d chars in -> %-6d chars out   %s',
        $s.chars, $u.chars, $u.chars < $s.chars ?? 'smaller' !! 'larger');
}
```

```output
0      chars in -> 1      chars out   larger
1      chars in -> 3      chars out   larger
2      chars in -> 5      chars out   larger
5      chars in -> 9      chars out   larger
11     chars in -> 19     chars out   larger
200    chars in -> 104    chars out   smaller
```

Short strings grow. Break-even is well above a hundred characters of English,
so this is for the payload, not for the key.

## Non-ASCII

```raku name="unicode"
use Compress::LZString;

for "héllo wörld", "日本語テキスト日本語テキスト", "\c[PILE OF POO]" -> $s {
    my $u = lz-compress-uri($s);
    say sprintf('%-22s -> %2d chars, round trip %s',
        $s.raku, $u.chars, lz-decompress-uri($u) eq $s ?? 'exact' !! 'DIFFERS');
}
```

```output
"héllo wörld"          -> 21 chars, round trip exact
"日本語テキスト日本語テキスト"       -> 27 chars, round trip exact
"💩"                    ->  7 chars, round trip exact
```

## The one thing to know

The empty string round-trips, but handing an empty string **to** a
decompressor returns an undefined `Str`.

```raku name="empty-trap"
use Compress::LZString;

say 'lz-compress-base64("")        : ', lz-compress-base64('').raku;
say 'lz-decompress-base64("Q===")  : ', lz-decompress-base64('Q===').raku;
say '  — so the codec is symmetric';
say '';
say 'but:';
say 'lz-decompress-base64("")      : ', lz-decompress-base64('').raku;
say 'lz-decompress-uri("")         : ', lz-decompress-uri('').raku;
say 'lz-decompress(Buf[uint16])    : ', lz-decompress(Buf[uint16]).raku;
```

```output
lz-compress-base64("")        : "Q==="
lz-decompress-base64("Q===")  : ""
  — so the codec is symmetric

but:
lz-decompress-base64("")      : Str
lz-decompress-uri("")         : Str
lz-decompress(Buf[uint16])    : ""
```

The guard in the source is `return "" without $input; return Str if $input eq
""` — the undefined case returns the empty string and the empty case returns
undefined, which is precisely backwards from what anyone would expect.

This is the exact shape a caller meets in production: a database column or a
`localStorage` slot holding `''` rather than the encoded empty string. Under
Rakudo, using the result in string context then warns; under Raku++ it
silently concatenates as `""`.

Normalise with `//  ''` at your own call site.

## Where the two engines differ

Only on stderr. Rakudo emits a stream of `Use of uninitialized value
@chars[4] of type Any in string context` from the decoder when it reads past
the end of malformed input; Raku++ emits none. The returned values are
identical.

Two things to guard against, the same on both engines. **No invalid input is
ever an error** — every malformed payload returns `""` or an undefined `Str`,
never an exception. And cross-feeding the two six-bit alphabets **silently
truncates** rather than failing: the base64 and URI alphabets agree on their
first 63 characters and differ only at index 63, so most payloads survive the
swap and a few do not, which is the worst kind of bug. Pair each compressor
with its own decompressor.
