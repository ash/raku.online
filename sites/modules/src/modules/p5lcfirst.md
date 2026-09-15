---
name: P5lcfirst
version: 0.0.12
auth: zef:lizmat
kind: Distribution · Perl 5 compatibility
summary: Perl's `lcfirst` and `ucfirst` — which uppercase the first character
  where Raku's `.tc` titlecases it.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5lcfirst
source: https://github.com/lizmat/P5lcfirst.git
---

## What it is for

Lower-casing or upper-casing just the first character, leaving the rest alone.
Raku has `.tc` and `.lc`, but `.tc` is *titlecase*, which is not the same
operation — and Perl code says `ucfirst`.

## Using it

```raku name="basics"
use P5lcfirst;

say 'lcfirst("HELLO")  = ', lcfirst('HELLO').raku;
say 'ucfirst("hello")  = ', ucfirst('hello').raku;
say 'lcfirst("hello")  = ', lcfirst('hello').raku;
say 'ucfirst("HELLO")  = ', ucfirst('HELLO').raku;
say '';
say 'the REST of the string is untouched, which is the whole point:';
say '  ucfirst("mcDONALD") = ', ucfirst('mcDONALD').raku;
say '  lcfirst("XMLParser") = ', lcfirst('XMLParser').raku;
say '';
say 'edges:';
for '', 'a', '1abc' -> $s {
    say sprintf('  ucfirst(%-8s) = %-10s lcfirst(%-8s) = %s',
                $s.raku, ucfirst($s).raku, $s.raku, lcfirst($s).raku);
}
```

```output
lcfirst("HELLO")  = "hELLO"
ucfirst("hello")  = "Hello"
lcfirst("hello")  = "hello"
ucfirst("HELLO")  = "HELLO"

the REST of the string is untouched, which is the whole point:
  ucfirst("mcDONALD") = "McDONALD"
  lcfirst("XMLParser") = "xMLParser"

edges:
  ucfirst(""      ) = ""         lcfirst(""      ) = ""
  ucfirst("a"     ) = "A"        lcfirst("a"     ) = "a"
  ucfirst("1abc"  ) = "1abc"     lcfirst("1abc"  ) = "1abc"
```

## The one thing to know

`ucfirst` **uppercases** where Raku's `.tc` **titlecases**. For the handful of
Unicode characters where those differ, the two give different answers.

```raku name="titlecase"
use P5lcfirst;

my $dz = "\c[LATIN SMALL LETTER DZ WITH CARON]";
say 'the digraph ǆ (U+01C6):';
say '  ucfirst  -> ', ucfirst($dz).raku, '  ', ucfirst($dz).substr(0, 1).uniname;
say '  .tc      -> ', $dz.tc.raku, '  ', $dz.tc.substr(0, 1).uniname;
say '';
say 'Unicode gives that character three cases, not two: a lowercase ǆ, a';
say 'titlecase ǅ and an uppercase Ǆ. ucfirst picks the uppercase one and';
say '.tc picks the titlecase one, and for a word-initial letter the';
say 'titlecase form is the correct typography.';
say '';
say 'the same split applies to the other digraphs:';
for "\c[LATIN SMALL LETTER LJ]", "\c[LATIN SMALL LETTER NJ]",
    "\c[LATIN SMALL LETTER DZ]" -> $c {
    say sprintf('  %s : ucfirst %-4s   .tc %-4s   differ ? %s',
                $c, ucfirst($c).raku, $c.tc.raku, ucfirst($c) ne $c.tc);
}
say '';
say 'for ASCII, and for every ordinary accented letter, the two agree:';
say '  ucfirst("hello") eq "hello".tc : ', ucfirst('hello') eq 'hello'.tc;
say '  ucfirst("élan")  eq "élan".tc  : ',
    ucfirst("\c[LATIN SMALL LETTER E WITH ACUTE]lan") eq "\c[LATIN SMALL LETTER E WITH ACUTE]lan".tc;
```

```output
the digraph ǆ (U+01C6):
  ucfirst  -> "Ǆ"  LATIN CAPITAL LETTER DZ WITH CARON
  .tc      -> "ǅ"  LATIN CAPITAL LETTER D WITH SMALL LETTER Z WITH CARON

Unicode gives that character three cases, not two: a lowercase ǆ, a
titlecase ǅ and an uppercase Ǆ. ucfirst picks the uppercase one and
.tc picks the titlecase one, and for a word-initial letter the
titlecase form is the correct typography.

the same split applies to the other digraphs:
  ǉ : ucfirst "Ǉ"    .tc "ǈ"    differ ? True
  ǌ : ucfirst "Ǌ"    .tc "ǋ"    differ ? True
  ǳ : ucfirst "Ǳ"    .tc "ǲ"    differ ? True

for ASCII, and for every ordinary accented letter, the two agree:
  ucfirst("hello") eq "hello".tc : True
  ucfirst("élan")  eq "élan".tc  : True
```

## Where the two engines differ

Nothing. Both names, both operations and the digraph split behave identically.

```raku name="portable"
use P5lcfirst;

say 'the end state of a port is core Raku:';
say '  "hello".tc     = ', 'hello'.tc.raku, '   <- titlecase the first character';
say '  "HELLO".lcfirst — no such method; use a substr:';
sub lc-first(Str $s) { $s.chars ?? $s.substr(0, 1).lc ~ $s.substr(1) !! $s }
say '  lc-first("HELLO") = ', lc-first('HELLO').raku;
say '';
say 'and if you specifically want the uppercase rather than the titlecase';
say 'first character, say so:';
sub uc-first(Str $s) { $s.chars ?? $s.substr(0, 1).uc ~ $s.substr(1) !! $s }
my $dz = "\c[LATIN SMALL LETTER DZ WITH CARON]";
say '  uc-first(dz) = ', uc-first($dz).raku, '   .tc = ', $dz.tc.raku;
say '';
say 'that is the decision this module makes for you, and the reason to';
say 'make it deliberately when the port is finished.';
```

```output
the end state of a port is core Raku:
  "hello".tc     = "Hello"   <- titlecase the first character
  "HELLO".lcfirst — no such method; use a substr:
  lc-first("HELLO") = "hELLO"

and if you specifically want the uppercase rather than the titlecase
first character, say so:
  uc-first(dz) = "Ǆ"   .tc = "ǅ"

that is the decision this module makes for you, and the reason to
make it deliberately when the port is finished.
```
