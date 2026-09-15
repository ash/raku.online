---
name: LZW::Revolunet
version: 0.3.2
auth: none stated
kind: Distribution · compression
summary: A port of a JavaScript LZW routine that replaces repeated substrings
  with single characters drawn from a private code space.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/?/LZW::Revolunet
source: https://gitlab.com/pheix/lzw-revolunet-perl6.git
---

## What it is for

LZW builds a dictionary of repeated substrings as it goes and replaces each
with a code, which is how GIF and the old `compress` worked. This
implementation is a port of a JavaScript routine, and it keeps that routine's
defining choice: both input and output are `Str`s, never byte buffers, with
the dictionary codes drawn from a private Unicode range starting at codepoint
97000.

That makes it a string-to-string transform that interoperates with the same
JavaScript, rather than a byte compressor.

## Round trips

```raku name="roundtrip"
use LZW::Revolunet;

my $lzw = LZW::Revolunet.new;

for 'hello hello hello hello',
    'TOBEORNOTTOBEORTOBEORNOT',
    'a' x 30,
    'abc' -> $in {
    my $c = $lzw.compress(s => $in);
    my $d = $lzw.decompress(s => $c);
    say sprintf('%3d chars in -> %3d chars out   round trip %s',
        $in.chars, $c.chars, $d eq $in ?? 'exact' !! 'DIFFERS');
}
```

```output
 23 chars in ->  14 chars out   round trip exact
 24 chars in ->  16 chars out   round trip exact
 30 chars in ->   8 chars out   round trip exact
  3 chars in ->   3 chars out   round trip exact
```

Every round trip is exact for ASCII. The character counts go down, which is
the part that looks like compression.

## What the codes actually are

```raku name="codes"
use LZW::Revolunet;

my $lzw = LZW::Revolunet.new;
my $c = $lzw.compress(s => 'TOBEORNOTTOBEORTOBEORNOT');

say 'compressed codepoints : ', $c.ords.List.raku;
say '';
say 'the highest one       : ', $c.ords.max, '  (U+', $c.ords.max.base(16), ')';
say 'that character alone encodes to ',
    $c.ords.max.chr.encode('utf8').bytes, ' UTF-8 bytes';
```

```output
compressed codepoints : (84, 79, 66, 69, 79, 82, 78, 79, 84, 97000, 97002, 97004, 97009, 97003, 97005, 97007)

the highest one       : 97009  (U+17AF1)
that character alone encodes to 4 UTF-8 bytes
```

Which is the problem.

## The one thing to know

This compressor makes text **bigger**, and its own ratio reporting hides it.

```raku name="growth-trap"
use LZW::Revolunet;

my $lzw = LZW::Revolunet.new;

printf("%-34s %6s %7s %8s %9s %8s\n",
       'input', 'chars', 'bytes', 'c.bytes', 'ratio()', 'verdict');
for 'TOBEORNOTTOBEORTOBEORNOT', 'hello hello hello hello',
    'a' x 60, 'abcdefghijklmnopqrstuvwxyz',
    ('the quick brown fox ' x 5) -> $in {
    my $c  = $lzw.compress(s => $in);
    my $ib = $in.encode('utf8').bytes;
    my $cb = $c.encode('utf8').bytes;
    printf("%-34s %6d %7d %8d %9d %8s\n",
        $in.chars > 32 ?? $in.substr(0, 29) ~ '...' !! $in,
        $in.chars, $ib, $cb, $lzw.get_ratio(),
        $cb < $ib ?? 'smaller' !! 'LARGER');
}
```

```output
input                               chars   bytes  c.bytes   ratio()  verdict
TOBEORNOTTOBEORTOBEORNOT               24      24       37       -25   LARGER
hello hello hello hello                23      23       38       -31   LARGER
aaaaaaaaaaaaaaaaaaaaaaaaaaaaa...       60      60       41        48  smaller
abcdefghijklmnopqrstuvwxyz             26      26       26         0   LARGER
the quick brown fox the quick...      100     100      153       -20   LARGER
```

The dictionary codes start at U+17AE8, which costs **four UTF-8 bytes each**,
replacing substrings that were often two or three ASCII bytes. Four of those
five inputs grew.

And `get_bytes` — which `get_ratio` is computed from — sizes a codepoint by
how many bytes the *number* needs rather than how many the character takes, so
it charges three bytes for a four-byte character and undercounts every
compressed string. The classic LZW demonstration string went from 24 bytes to
37 while the reported ratio said −25.

Measure `.encode('utf8').bytes` yourself if the size is what you care about.
Use this for interoperability with the JavaScript library, not for
compression.

## Where the two engines differ

On non-Latin-1 input, and the boundary is exactly U+0100.

Rakudo **throws** `Error encoding Latin-1 string: could not encode codepoint
256` for any character above U+00FF, so under Rakudo the module is usable only
on Latin-1 text. Raku++'s Latin-1 encoder is lenient, so `"中文中文"`
round-trips exactly there.

Rakudo also emits a standing `Use of uninitialized value @out` warning from
the decompressor on every call, which Raku++ does not.

Two things that are the same on both. **`compress` on the empty string
throws** while `decompress` on it returns `""`, so the pair is asymmetric at
that one input. And the decompressor **never rejects anything**: a plain
string, a lone dictionary code, a code past anything the compressor ever
issued — all decode to silent garbage rather than an error.

The distribution declares no `auth`.
