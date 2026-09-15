---
name: Number::Bytes::Human
version: 0.0.4
auth: zef:raku-community-modules
kind: Distribution · formatting
summary: Convert byte counts to and from short human-readable strings —
  1048576 to 1M and back — using binary magnitudes.
status: partial
suite: 3 files, green
tested: 2026-09-15
license: MIT
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Number::Bytes::Human
source: https://github.com/raku-community-modules/Number-Bytes-Human.git
---

## What it is for

`du -h` prints `1.4M` rather than `1468006`, because nobody reads seven digits
of bytes. Any tool that reports sizes to a person wants the same thing, and
any tool that reads a size from a configuration file wants the reverse.

This distribution is both directions, available either as subs or as class
methods.

## Formatting

```raku name="format"
use Number::Bytes::Human :functions;

for 0, 1, 999, 1023, 1024, 1025, 1536, 1000000, 1048576, 1073741824 -> $n {
    say sprintf('%-12d => %s', $n, format-bytes($n));
}
```

```output
0            => 0B
1            => 1B
999          => 999B
1023         => 1023B
1024         => 1K
1025         => 1K
1536         => 2K
1000000      => 977K
1048576      => 1M
1073741824   => 1G
```

Magnitudes are **binary** — 1024-based — but labelled with the SI-looking
single letters `K`, `M`, `G`, `T`, `P`. So `1000` formats as `1000B` and
`1024` as `1K`, which is `du -h`'s convention rather than a disk
manufacturer's.

## Parsing

```raku name="parse"
use Number::Bytes::Human :functions;

for '1K', '1KB', '1M', '1T', '1P' -> $s {
    say sprintf('%-6s => %d', $s.raku, parse-bytes($s));
}
say '';
say 'malformed input is refused:';
for '1', '1024', 'banana', '' -> $s {
    my $r = try parse-bytes($s);
    say sprintf('  %-10s => %s', $s.raku, $! ?? 'refused' !! $r.Str);
}
```

```output
"1K"   => 1024
"1KB"  => 1024
"1M"   => 1048576
"1T"   => 1099511627776
"1P"   => 1125899906842624

malformed input is refused:
  "1"        => refused
  "1024"     => refused
  "banana"   => refused
  ""         => refused
```

Every malformed input throws, which is the right behaviour — and which makes
the next section worse.

## The class

```raku name="class"
use Number::Bytes::Human;

say 'no import tag needed for the methods:';
say '  .format(1048576) = ', Number::Bytes::Human.format(1048576);
say "  .parse('1M')     = ", Number::Bytes::Human.parse('1M');
```

```output
no import tag needed for the methods:
  .format(1048576) = 1M
  .parse('1M')     = 1048576
```

The subs need the **`:functions`** import tag; the class methods do not. A
plain `use Number::Bytes::Human;` leaves `&format-bytes` undefined, and
Rakudo will refuse to compile a file that calls it while Raku++ only fails at
runtime — so code written under one engine without the tag appears to work
until a symbol is actually called.

## The one thing to know

`parse-bytes` is case-sensitive on the suffix, and a lowercase one returns
**`0`** instead of raising.

```raku name="case-trap"
use Number::Bytes::Human :functions;

for '1K', '1k', '1M', '1m', '1G', '1g' -> $s {
    my $r = try parse-bytes($s);
    say sprintf('%-6s => %s', $s.raku, $! ?? 'refused' !! $r.Str);
}
say '';
say 'every other malformed input throws, so the guard clearly exists —';
say 'lowercase slips past it and produces a plausible-looking number.';
```

```output
"1K"   => 1024
"1k"   => 0
"1M"   => 1048576
"1m"   => 0
"1G"   => 1073741824
"1g"   => 0

every other malformed input throws, so the guard clearly exists —
lowercase slips past it and produces a plausible-looking number.
```

`1k`, `1m` and `1g` are exactly how people type these by hand, in
configuration files and on command lines. A size limit that parses to `0`
fails open or closed depending on which side of a comparison it lands, and
nothing anywhere reports it.

Upper-case the suffix before parsing.

## Where the two engines differ

On a fractional byte count, and on the missing import tag.

`format-bytes(0.5)` gives `0B` under Raku++ and `1B` under Rakudo, so
fractional inputs are not portable — round to an integer first. Rakudo also
emits `Use of uninitialized value` from the parser's table lookup where
Raku++ is silent, which is the lowercase bug announcing itself on one engine
only.

And without `:functions`, Rakudo refuses to compile and Raku++ fails at
runtime, as above.

One thing that is the same on both and worth planning for: **the round trip
does not close**. `1536` formats to `2K` and parses back to `2048`. Formatting
is lossy by design — that is what makes it readable — so never format a value
you intend to read back.
