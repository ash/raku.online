---
name: CCColor
version: 0.0.2
auth: github:ccworld1000
kind: Distribution · colour
summary: A hex colour string to four exact fractions of 255 — where lowercase
  hex silently returns opaque black.
status: divergent
suite: no test files, so trivially green
tested: 2026-09-15
license: GPL-2.0
depends: none beyond the core
raku-land: https://raku.land/github:ccworld1000/CCColor
source: https://github.com/ccworld1000/CCColor.git
---

## What it is for

Graphics APIs want colour components as fractions in 0..1; CSS and designers
write them as hex. This distribution converts one to the other, returning four
`Rat` values so the fractions stay exact: `136/255` comes back as `<8/15>`,
not as a rounded float.

## Converting

```raku name="basics"
use CCColor;

for '#FF8800', 'FF8800', '#FF880080', '#0000FF' -> $hex {
    my @c = hex2rgba($hex);
    say sprintf('  %-12s -> (%s)  [%d %d %d %d]',
                $hex.raku, @c.map({ .round(0.0001) }).join(', '),
                |@c.map({ ($_ * 255).round }));
}
say '';
say 'the components are exact Rats, not floats:';
my @c = hex2rgba('#FF8800');
say '  types  : ', @c.map({ .WHAT.^name }).join(', ');
say '  green  : ', @c[1].raku, '  = 136/255';
say '';
say 'alpha defaults to 0xFF when the string carries only three bytes.';
say 'whitespace is stripped globally, so "# F F 8 8 0 0" parses too:';
say '  ', hex2rgba('# F F 8 8 0 0').map({ ($_ * 255).round }).join(' ');
```

```output
  "#FF8800"    -> (1, 0.5333, 0, 1)  [255 136 0 255]
  "FF8800"     -> (1, 0.5333, 0, 1)  [255 136 0 255]
  "#FF880080"  -> (1, 0.5333, 0, 0.502)  [255 136 0 128]
  "#0000FF"    -> (0, 0, 1, 1)  [0 0 255 255]

the components are exact Rats, not floats:
  types  : Rat, Rat, Rat, Rat
  green  : <8/15>  = 136/255

alpha defaults to 0xFF when the string carries only three bytes.
whitespace is stripped globally, so "# F F 8 8 0 0" parses too:
  255 136 0 255
```

## The one thing to know

Lowercase hex silently returns opaque black.

```raku name="lowercase"
use CCColor;

for '#FF8800', '#ff8800', '#AABBCC', '#aabbcc' -> $hex {
    say sprintf('  %-12s -> [%s]', $hex,
                hex2rgba($hex).map({ ($_ * 255).round }).join(' '));
}
say '';
say 'the validator tests a character with `$c cmp "F"` and rejects anything';
say 'that sorts higher. That is correct for G..Z and catastrophic for a..f,';
say 'whose codepoints (97..102) all sort above "F" (70).';
say '';
say 'the first rejected pair aborts the scan with `last`, so every channel';
say 'keeps its default "0" and alpha keeps 0xFF — opaque black, no';
say 'exception, no return code, and the diagnostic sits behind an';
say 'unreachable debug flag. Lowercase is the dominant CSS convention.';
say '';
say 'upper-case at the call site:';
sub rgba(Str $hex) { hex2rgba($hex.uc) }
say '  rgba("#ff8800") -> [', rgba('#ff8800').map({ ($_ * 255).round }).join(' '), ']';
```

```output
  #FF8800      -> [255 136 0 255]
  #ff8800      -> [0 0 0 255]
  #AABBCC      -> [170 187 204 255]
  #aabbcc      -> [0 0 0 255]

the validator tests a character with `$c cmp "F"` and rejects anything
that sorts higher. That is correct for G..Z and catastrophic for a..f,
whose codepoints (97..102) all sort above "F" (70).

the first rejected pair aborts the scan with `last`, so every channel
keeps its default "0" and alpha keeps 0xFF — opaque black, no
exception, no return code, and the diagnostic sits behind an
unreachable debug flag. Lowercase is the dominant CSS convention.

upper-case at the call site:
  rgba("#ff8800") -> [255 136 0 255]
```

## The CSS shorthand is wrong, not unsupported

```raku name="shorthand"
use CCColor;

say 'a 1..4 character string is read as one hex NIBBLE per channel:';
for '#F80', '#FFF', '#ABCD', '#1' -> $hex {
    say sprintf('  %-8s -> [%s]', $hex,
                hex2rgba($hex).map({ ($_ * 255).round }).join(' '));
}
say '';
say '#FFF is near-black, not white; #F80 is [15 8 0], not [255 136 0].';
say 'and #ABCD is read as RGBA nibbles, so its alpha is 13/255 — almost';
say 'transparent.';
say '';
say 'expand the shorthand yourself before calling:';
sub expand(Str $h is copy) {
    $h .= subst('#', '');
    $h = $h.comb.map({ $_ x 2 }).join if $h.chars == 3;
    hex2rgba($h.uc)
}
say '  expand("#f80") -> [', expand('#f80').map({ ($_ * 255).round }).join(' '), ']';
```

```output
a 1..4 character string is read as one hex NIBBLE per channel:
  #F80     -> [15 8 0 255]
  #FFF     -> [15 15 15 255]
  #ABCD    -> [10 11 12 13]
  #1       -> [1 0 0 255]

#FFF is near-black, not white; #F80 is [15 8 0], not [255 136 0].
and #ABCD is read as RGBA nibbles, so its alpha is 13/255 — almost
transparent.

expand the shorthand yourself before calling:
  expand("#f80") -> [255 136 0 255]
```

An odd-length string of five or more reads its one-character tail as a byte,
and any invalid character anywhere yields a *partial* result rather than an
error.

## Where the two engines differ

One case: a `Str` type object as the argument. Raku++ answers `(0 0 0 1)`;
Rakudo refuses with `Cannot resolve caller trim(Str:U:)`. Guard the argument
and the two agree everywhere else.

```raku name="edges"
use CCColor;

say 'an empty string prints two diagnostics — to STDOUT, which will';
say 'corrupt a program whose stdout is data — and answers black:';
say '  hex2rgba("") -> [', hex2rgba('').map({ ($_ * 255).round }).join(' '), ']';
say '';
say 'the portable wrapper:';
sub rgba(Str:D $raw) {
    my $h = $raw.subst(/\s/, '', :g).subst(/^'#'/, '').uc;
    die "not hex: $raw" unless $h ~~ /^ <[0..9A..F]>+ $/;
    die "wrong length: $raw" unless $h.chars == 6 | 8;
    hex2rgba($h)
}
for '#ff8800', '  #FF8800  ', '#GG0000', '#F80' -> $raw {
    my $r = try rgba($raw);
    say sprintf('  %-14s -> %s', $raw.raku,
                $! ?? $!.message !! '[' ~ $r.map({ ($_ * 255).round }).join(' ') ~ ']');
}
```

```output
an empty string prints two diagnostics — to STDOUT, which will
corrupt a program whose stdout is data — and answers black:
Error: ill hex string
Error: ill hex string
  hex2rgba("") -> [0 0 0 255]

the portable wrapper:
  "#ff8800"      -> [255 136 0 255]
  "  #FF8800  "  -> [255 136 0 255]
  "#GG0000"      -> not hex: #GG0000
  "#F80"         -> wrong length: #F80
```
