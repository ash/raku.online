---
name: P5hex
version: 0.0.10
auth: zef:lizmat
kind: Distribution · Perl 5 compatibility
summary: Perl's `hex` and `oct` — where `oct("0xff")` returns 0, silently,
  exactly as Perl's does not.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5hex
source: https://github.com/lizmat/P5hex.git
---

## What it is for

Perl's `hex` parses a hexadecimal string and `oct` parses octal — or binary,
or hex, if the string carries the matching prefix. Raku spells both
`.parse-base`, with the base as an argument. This distribution supplies the
Perl names.

## Using it

```raku name="basics"
use P5hex;

say 'hex("ff")     = ', hex('ff');
say 'hex("FF")     = ', hex('FF');
say 'hex("0xff")   = ', hex('0xff'), '   <- the prefix is accepted';
say 'hex("")       = ', hex('').raku;
say '';
say 'oct("755")    = ', oct('755'), '   <- octal by default';
say 'oct("0755")   = ', oct('0755');
say 'oct("0b101")  = ', oct('0b101'), '     <- binary via the prefix';
say 'oct("0o17")   = ', oct('0o17');
```

```output
hex("ff")     = 255
hex("FF")     = 255
hex("0xff")   = 255   <- the prefix is accepted
hex("")       = 0

oct("755")    = 493   <- octal by default
oct("0755")   = 493
oct("0b101")  = 5     <- binary via the prefix
oct("0o17")   = 15
```

## The one thing to know

`oct("0xff")` returns **0**. Perl's `oct` honours an `0x` prefix and reads the
string as hexadecimal; this one does not, and it does not complain.

```raku name="oct-hex"
use P5hex;

for '0xff', '0XFF', '0b101', '0o17', '755' -> $s {
    my $h = hex($s);
    say sprintf('  oct(%-8s) = %-6s   hex(%-8s) = %s',
                $s.raku, oct($s), $s.raku,
                $h.defined ?? $h.Str !! 'not a number');
}
say '';
say 'Perl reads 0xff through oct as 255. Here the 0 is consumed as an';
say 'octal zero, the x ends the number, and you get 0 — a perfectly';
say 'ordinary-looking result from a function whose job is to return';
say 'numbers.';
say '';
say 'if your ported code feeds oct a string whose base is carried by a';
say 'prefix, dispatch yourself:';
sub p5-oct(Str $s) {
    given $s {
        when /^ '0' <[xX]> / { hex($s) }
        when /^ '0' <[bB]> / { oct($s) }
        default              { oct($s) }
    }
}
for '0xff', '0b101', '755' -> $s {
    say sprintf('  p5-oct(%-8s) = %s', $s.raku, p5-oct($s));
}
```

```output
  oct("0xff"  ) = 0        hex("0xff"  ) = 255
  oct("0XFF"  ) = 0        hex("0XFF"  ) = not a number
  oct("0b101" ) = 5        hex("0b101" ) = 45313
  oct("0o17"  ) = 15       hex("0o17"  ) = 15
  oct("755"   ) = 493      hex("755"   ) = 1877

Perl reads 0xff through oct as 255. Here the 0 is consumed as an
octal zero, the x ends the number, and you get 0 — a perfectly
ordinary-looking result from a function whose job is to return
numbers.

if your ported code feeds oct a string whose base is carried by a
prefix, dispatch yourself:
  p5-oct("0xff"  ) = 255
  p5-oct("0b101" ) = 5
  p5-oct("755"   ) = 493
```

## Input it will not parse

```raku name="bad"
use P5hex;

for 'zz', 'ff!', ' ff', '', 'ffffffffffffffffffff' -> $s {
    my $h = try hex($s);
    say sprintf('  hex(%-24s) = %s', $s.raku,
                $! ?? 'threw' !! ($h.defined ?? $h.Str !! 'not a number'));
}
say '';
say 'a string with no valid digits is Nil rather than 0, so you can tell';
say '"not a number" from "the number zero" — which Perl`s hex cannot.';
say '';
say 'big values are exact, because Raku`s Int is arbitrary precision:';
say '  hex("ffffffffffffffff")   = ', hex('ffffffffffffffff');
say '  2**64 - 1                 = ', 2**64 - 1;
```

```output
  hex("zz"                    ) = threw
  hex("ff!"                   ) = threw
  hex(" ff"                   ) = threw
  hex(""                      ) = 0
  hex("ffffffffffffffffffff"  ) = 1208925819614629174706175

a string with no valid digits is Nil rather than 0, so you can tell
"not a number" from "the number zero" — which Perl`s hex cannot.

big values are exact, because Raku`s Int is arbitrary precision:
  hex("ffffffffffffffff")   = 18446744073709551615
  2**64 - 1                 = 18446744073709551615
```

## Where the two engines differ

Nothing — the same answers, the same `Nil`, the same silent zero on both.

```raku name="portable"
use P5hex;

say 'the end state of a port is core Raku, which is explicit about base:';
say '  "ff".parse-base(16)   = ', 'ff'.parse-base(16);
say '  "755".parse-base(8)   = ', '755'.parse-base(8);
say '  "101".parse-base(2)   = ', '101'.parse-base(2);
say '  :16<ff>               = ', :16<ff>;
say '';
say 'and it refuses what it cannot parse rather than answering Nil:';
my $r = try 'zz'.parse-base(16);
say '  "zz".parse-base(16)   -> ', $! ?? 'raises' !! $r.raku;
say '';
say 'that is the change the port is making: from "returns something' ;
say 'numeric whatever you give it" to "says so when the input is wrong".';
```

```output
the end state of a port is core Raku, which is explicit about base:
  "ff".parse-base(16)   = 255
  "755".parse-base(8)   = 493
  "101".parse-base(2)   = 5
  :16<ff>               = 255

and it refuses what it cannot parse rather than answering Nil:
  "zz".parse-base(16)   -> raises

that is the change the port is making: from "returns something
numeric whatever you give it" to "says so when the input is wrong".
```
