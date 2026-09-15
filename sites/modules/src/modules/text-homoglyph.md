---
name: Text::Homoglyph
version: 0.0.2
auth: github:MattOates
kind: Distribution · Unicode
summary: A table of Unicode look-alikes for each printable ASCII character,
  behind one function whose guard checks length instead of membership.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:MattOates/Text::Homoglyph
source: git://github.com/MattOates/Text--Homoglyph.git
---

## What it is for

A homoglyph is a character that looks like another one: Cyrillic `а` beside
Latin `a`, Greek `Ο` beside Latin `O`. They are how a spoofed domain name or
a lookalike username gets past a human reader.

This distribution holds one table mapping each of the 95 printable ASCII
characters to a handful of characters that resemble it, and exposes exactly
one function to read it.

## The whole API

```raku name="lookup"
use Text::Homoglyph;

my @g = homoglyphs('a');
say 'homoglyphs("a") returns : ', @g.elems, ' elements';
say 'codepoints              : ', @g.map({ 'U+' ~ .ord.base(16).fmt('%04s') }).join(' ');
say 'names                   : ', @g[1..*].map(*.uniname).join(' | ');
say '';
say 'the first element is the INPUT itself, so .pick returns the';
say 'original character about one time in four.';
```

```output
homoglyphs("a") returns : 4 elements
codepoints              : U+0061 U+0251 U+0430 U+1972
names                   : LATIN SMALL LETTER ALPHA | CYRILLIC SMALL LETTER A | TAI LE LETTER TONE-4

the first element is the INPUT itself, so .pick returns the
original character about one time in four.
```

Every one of the 95 printable ASCII characters has an entry:

```raku name="coverage"
use Text::Homoglyph;

my $covered = (0x20 .. 0x7E).grep({ homoglyphs(.chr).elems > 1 }).elems;
say "printable ASCII with a mapping : $covered of 95";
say '';
for '0', 'O', 'v' -> $c {
    say sprintf('%s -> %s', $c, homoglyphs($c).map({ 'U+' ~ .ord.base(16).fmt('%04s') }).join(' '));
}
```

```output
printable ASCII with a mapping : 95 of 95

0 -> U+0030 U+004F U+1D67E
O -> U+004F U+039F U+041E U+2C9E
v -> U+0076 U+1D20 U+2174 U+2228 U+22C1
```

Note `'0'` maps to the *ASCII letter* `O`, and `'v'` includes `∨` and `⋁` —
mathematical operators, not letters. Substituting into a formula changes what
the formula means.

## The one thing to know

The signature guard is `where $string.chars == 1`. That is a length test on
graphemes, not a membership test in the table — so every non-ASCII single
character gets past it and dies inside the sub, on a message that names
neither the argument nor the function.

```raku name="guard"
use Text::Homoglyph;

for 'a', 'ab', "\c[LATIN SMALL LETTER E WITH ACUTE]", "\c[CJK UNIFIED IDEOGRAPH-6F22]",
    "\c[CHRISTMAS TREE]", "\t" -> $c {
    my $r = try homoglyphs($c);
    say sprintf('%-28s chars=%d -> %s',
                $c.raku, $c.chars, $! ?? 'DIED' !! $r.elems ~ ' glyphs');
}
say '';
say 'the obvious loop $text.comb.map({ homoglyphs($_) }) therefore works';
say 'on ASCII and crashes on the first tab, newline or accented letter.';
say 'the guard the author wanted is a lookup, not a length.';
```

```output
"a"                          chars=1 -> 4 glyphs
"ab"                         chars=2 -> DIED
"é"                          chars=1 -> DIED
"漢"                          chars=1 -> DIED
"🎄"                          chars=1 -> DIED
"\t"                         chars=1 -> DIED

the obvious loop $text.comb.map({ homoglyphs($_) }) therefore works
on ASCII and crashes on the first tab, newline or accented letter.
the guard the author wanted is a lookup, not a length.
```

## Where the two engines differ

Nothing behavioural: the same inputs succeed and the same inputs fail on both
engines. Two wordings differ. Raku++ phrases the `Any` lookup failure as
`Cannot resolve caller comb(Any:U); the invocant is a type object` where
Rakudo says `No such method 'comb' for invocant of type 'Any'`, and Raku++
truncates the constraint message to `Constraint type check failed in binding
to parameter '$string'` without Rakudo's trailing `expected anonymous
constraint to be met but got Str ("ab")`.

A property worth knowing before you build anything on this table: it is not
symmetric, so a confusability set built by taking unions will not close.

```raku name="asymmetry"
use Text::Homoglyph;

say '0 -> O ? ', homoglyphs('0').grep('O').Bool;
say 'O -> 0 ? ', homoglyphs('O').grep('0').Bool;
say '';
say 'there is no way to reach the table itself (it is `my`-scoped inside';
say 'a package block) and no whole-string entry point. Per character is';
say 'the entire interface.';
```

```output
0 -> O ? True
O -> 0 ? False

there is no way to reach the table itself (it is `my`-scoped inside
a package block) and no whole-string entry point. Per character is
the entire interface.
```
