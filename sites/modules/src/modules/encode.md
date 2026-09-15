---
name: Encode
version: 0.0.4
auth: github:sergot
kind: Distribution · encoding
summary: Byte-to-text decoding for the legacy single-byte encodings the
  core does not carry — ISO-8859-2 and Windows-1251 above all — as one sub
  and three lookup tables.
status: full
suite: 7 files, green
tested: 2026-09-15
raku-land: https://raku.land/github:sergot/Encode
source: https://github.com/sergot/perl6-encode
---

## What it is for

Text from before UTF-8 won is still arriving: a CSV exported from an old
Windows application, a database column filled in 2003, a mail archive, a
government data set. Each byte is one character, and which character
depends on a code page the file does not name. Raku's core decoder knows
UTF-8, ASCII, Latin-1 and Windows-1252; it does not know Central European
ISO-8859-2 or Cyrillic Windows-1251, and those are exactly the two that a
Polish or Russian archive turns out to be in.

This distribution adds them, as plain byte-to-codepoint tables with one
routine over the top.

## Decoding a code page

```raku name="decode"
use Encode;

my $cyrillic = Buf[uint8].new(0xCF, 0xF0, 0xE8, 0xE2, 0xE5, 0xF2);
say Encode::decode('cp1251', $cyrillic);

my $polish = Buf[uint8].new(0xA3, 0xF3, 0x64, 0xBC);
say Encode::decode('latin2', $polish);

my $one = Buf[uint8].new(0xA3);
say Encode::decode('latin1', $one), ' ', Encode::decode('latin1', $one).ords;
say Encode::decode('latin2', $one), ' ', Encode::decode('latin2', $one).ords;

say Encode::decode('utf8', Buf[uint8].new(0x63, 0x61, 0x66, 0xC3, 0xA9));
say (try Encode::decode('utf-16', Buf[uint8].new(0x61))) // $!.message;
```

```output
Привет
Łódź
£ (163)
Ł (321)
café
Unknown encoding utf-16.
```

The same byte is a different letter in each table, which is the whole
problem the module solves: `0xA3` is a pound sign in Latin-1 and a crossed
L in Latin-2. Names are matched exactly and case-sensitively — `latin2`,
`iso-8859-2`, `cp1251`, `windows-1251`, `utf8`, `utf-8`, `ascii` and their
siblings all work, and `UTF-8` in capitals does not.

## The one thing to know

A module called Encode cannot encode. Its entire public surface is one
routine that decodes, and even that is not imported: `use Encode;` puts
nothing in your scope, so the name has to be written out in full.

```raku name="no-encode"
use Encode;

say Encode::decode('latin2', Buf[uint8].new(0xE6));
say (try { ::('&Encode::encode') ~~ Callable }) // False;
say (try { ::('&Encode::decode') ~~ Callable }) // False;

my $blob = 'café'.encode('latin-1');
say $blob.^name;
say Encode::decode('latin1', Buf[uint8].new($blob.list));
```

```output
ć
False
True
Blob[uint8]
café
```

Going the other way is your problem: the tables in the sub-units map bytes
to codepoints and would have to be inverted by hand. The last three lines
are the other trap, and it is a portability one. The parameter is declared
`Buf`, and `Str.encode` gives you a `Blob` — Raku++ accepts it and Rakudo
refuses it, so code written against one engine breaks on the other. Wrap it
in `Buf[uint8].new(...)`, as the example does, and it works on both.

One more thing worth knowing before trusting a decode: a byte with no
character in the target encoding is passed straight through as the
codepoint of the same number rather than rejected or replaced. Nothing
tells you the file was not really in the encoding you named.
