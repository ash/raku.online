---
name: P5chr
version: 0.0.10
auth: zef:lizmat
kind: Distribution · Perl 5 compatibility
summary: Perl's `chr` and `ord` — where `chr` above 127 answers a literal
  question mark carrying the codepoint you asked for in its `.ord`.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5chr
source: https://github.com/lizmat/P5chr.git
---

## What it is for

Perl's `chr` and `ord` have their own edge behaviour, and code being ported
relies on it: `ord` takes the first character of a string rather than
demanding a single one, and neither refuses an odd argument. This
distribution supplies them under their Perl names.

## Using it

```raku name="basics"
use P5chr;

say 'chr(65)      = ', chr(65).raku;
say 'ord("A")     = ', ord('A');
say 'ord("abc")   = ', ord('abc'), '   <- the first character, not an error';
say 'ord("")      = ', ord('').raku;
say 'chr(0)       = ', chr(0).ords.raku;
say 'chr(-1)      = ', chr(-1).ords.raku, '   <- the replacement character';
say '';
say 'round trip over printable ASCII : ',
    so (0x20 .. 0x7E).all.map({ ord(chr($_)) == $_ });
```

```output
chr(65)      = "A"
ord("A")     = 65
ord("abc")   = 97   <- the first character, not an error
ord("")      = Nil
chr(0)       = (0,).Seq
chr(-1)      = (65533,).Seq   <- the replacement character

round trip over printable ASCII : True
```

## The one thing to know

`chr` above 127 answers a literal `?`, and that character's `.ord` is 63 — so
the round trip silently fails and the value you get back is a plausible number.

```raku name="high"
use P5chr;

for 65, 126, 127, 128, 200, 255 -> $n {
    my $c = chr($n);
    say sprintf('  chr(%5d)  .ord = %-5d  .ords = %-8s  eq %d.chr ? %s',
                $n, $c.ord, $c.ords.raku, $n, $c eq $n.chr);
}
say '';
say 'above 127 the returned string IS a question mark — .ords is (63),';
say 'its UTF-8 encoding is the single byte 0x3F, and it is not `eq` the';
say 'character core Raku would give you.';
say '';
say 'but .ord answers the number you asked for. So the obvious';
say 'round-trip check passes while the string is wrong:';
say '  chr(200).ord == 200        : ', chr(200).ord == 200;
say '  chr(200) eq 200.chr        : ', chr(200) eq 200.chr;
say '  chr(200).encode("utf8")    : ',
    chr(200).encode('utf8').list.map({ .fmt('%02X') }).join(' ');
say '  200.chr.encode("utf8")     : ',
    200.chr.encode('utf8').list.map({ .fmt('%02X') }).join(' ');
say '';
say 'a byte-oriented Perl program that walks 0..255 through chr therefore';
say 'produces the right answer for the first 128 and question marks for';
say 'the rest — and every assertion it makes with .ord still passes.';
say '';
say 'for codepoints above 127, use core Raku:';
say '  200.chr    = ', 200.chr.raku;
say '  0x2603.chr = ', 0x2603.chr.raku;
```

```output
  chr(   65)  .ord = 65     .ords = (65,).Seq  eq 65.chr ? True
  chr(  126)  .ord = 126    .ords = (126,).Seq  eq 126.chr ? True
  chr(  127)  .ord = 127    .ords = (127,).Seq  eq 127.chr ? True
  chr(  128)  .ord = 128    .ords = (63,).Seq  eq 128.chr ? False
  chr(  200)  .ord = 200    .ords = (63,).Seq  eq 200.chr ? False
  chr(  255)  .ord = 255    .ords = (63,).Seq  eq 255.chr ? False

above 127 the returned string IS a question mark — .ords is (63),
its UTF-8 encoding is the single byte 0x3F, and it is not `eq` the
character core Raku would give you.

but .ord answers the number you asked for. So the obvious
round-trip check passes while the string is wrong:
  chr(200).ord == 200        : True
  chr(200) eq 200.chr        : False
  chr(200).encode("utf8")    : 3F
  200.chr.encode("utf8")     : C3 88

a byte-oriented Perl program that walks 0..255 through chr therefore
produces the right answer for the first 128 and question marks for
the rest — and every assertion it makes with .ord still passes.

for codepoints above 127, use core Raku:
  200.chr    = "È"
  0x2603.chr = "☃"
```

## Scoping the Perl semantics

```raku name="scoping"
{
    use P5chr;
    say 'inside a block with `use P5chr`:';
    say '  ord("abc")  = ', ord('abc'), '   <- the first character';
    say '  chr(200).ords = ', chr(200).ords.raku;
}
say '';
say 'outside it, core Raku is back:';
say '  "abc".ord   = ', 'abc'.ord;
say '  200.chr.ords= ', 200.chr.ords.raku;
say '';
say 'and `use P5chr ()` loads the distribution without importing either';
say 'name, which is how you take one of a pair — or neither:';
{
    use P5chr ();
    say '  with an empty import list, 200.chr.ords = ', 200.chr.ords.raku;
}
```

```output
inside a block with `use P5chr`:
  ord("abc")  = 97   <- the first character
  chr(200).ords = (63,).Seq

outside it, core Raku is back:
  "abc".ord   = 97
  200.chr.ords= (200,).Seq

and `use P5chr ()` loads the distribution without importing either
name, which is how you take one of a pair — or neither:
  with an empty import list, 200.chr.ords = (200,).Seq
```

## Where the two engines differ

Nothing. The same substitutions, the same `?`, the same defaults and the same
`ord('')` on both engines.

```raku name="portable"
use P5chr;

say 'the portable rule is simple: use this pair for the Perl argument';
say 'handling, and core Raku for anything above 127.';
say '';
say 'a wrapper that gives you both:';
sub p5-chr($n) { $n <= 127 ?? chr($n) !! $n.chr }
for 65, 200, 0x2603 -> $n {
    say sprintf('  p5-chr(%5d).ords = %-8s  really that codepoint ? %s',
                $n, p5-chr($n).ords.raku, p5-chr($n).ords[0] == $n);
}
say '';
say 'the distribution is one of lizmat`s P5 family — each supplies one';
say 'or two Perl builtins under their Perl names and semantics, so a port';
say 'can proceed routine by routine rather than all at once.';
```

```output
the portable rule is simple: use this pair for the Perl argument
handling, and core Raku for anything above 127.

a wrapper that gives you both:
  p5-chr(   65).ords = (65,).Seq  really that codepoint ? True
  p5-chr(  200).ords = (200,).Seq  really that codepoint ? True
  p5-chr( 9731).ords = (9731,).Seq  really that codepoint ? True

the distribution is one of lizmat`s P5 family — each supplies one
or two Perl builtins under their Perl names and semantics, so a port
can proceed routine by routine rather than all at once.
```
