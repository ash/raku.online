---
name: P5length
version: 0.0.9
auth: zef:lizmat
kind: Distribution · Perl 5 compatibility
summary: Perl's `length` — which returns undef for an undefined argument, and
  that undef still compares equal to zero.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5length
source: https://github.com/lizmat/P5length.git
---

## What it is for

Raku spells it `.chars`. Perl spells it `length`, and a ported program is full
of the word. This distribution supplies the Perl name with the Perl
behaviour, including the part that matters: `length(undef)` is `undef`, not 0.

## Using it

```raku name="basics"
use P5length;

say 'length("hello") = ', length('hello');
say 'length("")      = ', length('');
say 'length("héllo") = ', length("h\c[LATIN SMALL LETTER E WITH ACUTE]llo"),
    '   <- graphemes, as .chars counts them';
say '';
say 'a number goes through the Str coercion:';
say 'length(12345)   = ', length(12345);
say 'length(3.14)    = ', length(3.14);
```

```output
length("hello") = 5
length("")      = 0
length("héllo") = 5   <- graphemes, as .chars counts them

a number goes through the Str coercion:
length(12345)   = 5
length(3.14)    = 4
```

## The one thing to know

`length` of an undefined value returns a **type object**, and that type object
still compares equal to zero.

```raku name="undef"
use P5length;

my $r = length(Str);
say 'length(Str)         : ', $r.raku;
say '  .WHAT             : ', $r.WHAT.^name;
say '  .defined          : ', $r.defined;
say '  == 0              : ', ($r == 0);
say '';
say 'so the Perl guard ports correctly:';
say '  if defined length($x) { … }  -> ', $r.defined;
say '';
say 'and the one a Raku programmer would reach for does not:';
say '  if length($x) == 0 { … }     -> ', ($r == 0);
say '';
say 'an empty string and an undefined one are indistinguishable by that';
say 'test, which is exactly the distinction Perl`s length exists to make.';
say '';
say 'test .defined, not == 0:';
for 'hello', '', Str -> $x {
    my $l = length($x);
    say sprintf('  %-8s -> %s', $x.raku,
                $l.defined ?? "length $l" !! 'undefined');
}
```

```output
length(Str)         : Str
  .WHAT             : Str
  .defined          : False
  == 0              : True

so the Perl guard ports correctly:
  if defined length($x) { … }  -> False

and the one a Raku programmer would reach for does not:
  if length($x) == 0 { … }     -> True

an empty string and an undefined one are indistinguishable by that
test, which is exactly the distinction Perl`s length exists to make.

test .defined, not == 0:
  "hello"  -> length 5
  ""       -> length 0
  Str      -> undefined
```

## Where the two engines differ

Only in diagnostics. Rakudo emits `Use of uninitialized value of type Str in
numeric context` when you compare the undefined result to a number; Raku++
emits nothing. The *answers* are identical, which means a program that relies
on the comparison is equally wrong on both and only one engine tells you.

```raku name="portable"
use P5length;

say 'the portable idiom is the Perl one:';
sub describe($x) {
    my $l = length($x);
    $l.defined ?? "$l characters" !! 'undefined'
}
for 'hello', '', Str, 42 -> $x {
    say sprintf('  %-8s -> %s', $x.raku, describe($x));
}
say '';
say 'and the end state, once the port is done, is core Raku:';
say '  "hello".chars     = ', 'hello'.chars;
say '  (Str).chars       — raises rather than answering an undefined value';
say '  ($x // "").chars  = ', ((Str) // '').chars;
say '';
say 'note the last line: core Raku pushes you to decide what an undefined';
say 'string means, which is the change the port is really making.';
```

```output
the portable idiom is the Perl one:
  "hello"  -> 5 characters
  ""       -> 0 characters
  Str      -> undefined
  42       -> 2 characters

and the end state, once the port is done, is core Raku:
  "hello".chars     = 5
  (Str).chars       — raises rather than answering an undefined value
  ($x // "").chars  = 0

note the last line: core Raku pushes you to decide what an undefined
string means, which is the change the port is really making.
```
