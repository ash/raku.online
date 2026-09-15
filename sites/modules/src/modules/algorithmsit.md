---
name: AlgorithmsIT
version: 0.0.4
auth: zef:tbrowder
kind: Distribution · algorithms
summary: Knuth-Morris-Pratt transcribed from the textbook, with a one-based
  array class so the code reads like the pseudocode.
status: divergent
suite: 6 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:tbrowder/AlgorithmsIT
source: https://github.com/tbrowder/AlgorithmsIT.git
---

## What it is for

*Introduction to Algorithms* indexes its arrays from 1. Transcribing its
pseudocode into a 0-based language means re-deriving every index, and that is
where transcription bugs come from. This distribution supplies a one-based
array class so the code can be copied as written — and, as its first worked
example, the Knuth-Morris-Pratt string matcher from chapter 32.

## Matching

```raku name="basics"
use AlgorithmsIT :p1005, :p1006;
use AlgorithmsIT::Classes;

sub matches(Str $text, Str $pattern) {
    KMP-Matcher(ArrayOneBased.new($text), ArrayOneBased.new($pattern))
}

for <abababacaba ababaca>, <aaaaa aa>, <abcabcabc abc>,
    <abc zzz>, <aaa aaa> -> ($t, $p) {
    my @brute = (0 .. $t.chars - $p.chars).grep({ $t.substr($_, $p.chars) eq $p });
    say sprintf('  T=%-12s P=%-8s shifts %-14s brute %-14s %s',
                $t, $p, matches($t, $p).raku, @brute.raku,
                matches($t, $p).List eqv @brute.List ?? 'agree' !! 'DIFFER');
}
say '';
say 'the shifts are zero-based offsets into the text.';
```

```output
  T=abababacaba  P=ababaca  shifts [2]            brute [2]            agree
  T=aaaaa        P=aa       shifts [0, 1, 2, 3]   brute [0, 1, 2, 3]   agree
  T=abcabcabc    P=abc      shifts [0, 3, 6]      brute [0, 3, 6]      agree
  T=abc          P=zzz      shifts []             brute []             agree
  T=aaa          P=aaa      shifts [0]            brute [0]            agree

the shifts are zero-based offsets into the text.
```

```raku name="prefix"
use AlgorithmsIT :p1005, :p1006;
use AlgorithmsIT::Classes;

my $pi = Compute-Prefix-Function(ArrayOneBased.new('ababaca'));
say 'Compute-Prefix-Function("ababaca") : ', $pi.gist;
say 'the textbook pi for ababaca        : [ 0, 0, 1, 2, 3, 0, 1 ]';
say '';
say 'the two import tags are the book`s PAGE NUMBERS:';
say '  :p1005 gives KMP-Matcher';
say '  :p1006 gives Compute-Prefix-Function';
say 'a plain `use AlgorithmsIT` imports NEITHER.';
```

```output
Compute-Prefix-Function("ababaca") : [ 0, 0, 1, 2, 3, 0, 1 ]
the textbook pi for ababaca        : [ 0, 0, 1, 2, 3, 0, 1 ]

the two import tags are the book`s PAGE NUMBERS:
  :p1005 gives KMP-Matcher
  :p1006 gives Compute-Prefix-Function
a plain `use AlgorithmsIT` imports NEITHER.
```

## `ArrayOneBased`

```raku name="onebased"
use AlgorithmsIT::Classes;

my $a = ArrayOneBased.new('abc');
say 'new("abc")      : ', $a.gist;
say '  .elems        : ', $a.elems, '   .length : ', $a.length;
say '  [1]           : ', $a[1].raku, '   <- ONE-based';
say '  [0]           : ', $a[0].raku, '   <- the sentinel';
say '  [4]           : ', $a[4].raku, '   <- past the end, does not grow';
say '  .arr          : ', $a.arr.raku;
say '';
say 'three constructors:';
say '  new(5)        : ', ArrayOneBased.new(5).gist;
say '  new(3, 7)     : ', ArrayOneBased.new(3, 7).gist;
say '  new((10,20))  : ', ArrayOneBased.new((10, 20)).gist;
say '';
my $r = try ArrayOneBased.new(1);
say '  new(1)        : ', $! ?? 'refused — end must exceed start' !! $r.gist;
say '  use new((1,)) for a one-element array.';
say '';
say 'A1B is the same type : ', (A1B === ArrayOneBased);
```

```output
new("abc")      : [ a, b, c ]
  .elems        : 3   .length : 3
  [1]           : "a"   <- ONE-based
  [0]           : -1   <- the sentinel
  [4]           : Any   <- past the end, does not grow
  .arr          : [-1, "a", "b", "c"]

three constructors:
  new(5)        : [ 1, 2, 3, 4, 5 ]
  new(3, 7)     : [ 3, 4, 5, 6, 7 ]
  new((10,20))  : [ 10, 20 ]

  new(1)        : refused — end must exceed start
  use new((1,)) for a one-element array.

A1B is the same type : True
```

## The one thing to know

`ArrayOneBased` composes `Iterable` but never defines `iterator`, so every
list operation on it silently produces nothing.

```raku name="iterable"
use AlgorithmsIT::Classes;

my $a = ArrayOneBased.new('abc');
say 'it claims to do Iterable : ', ($a ~~ Iterable);
say '';
say 'so a guard that checks for iterability passes — and then';
say '`for $a { … }` quietly does nothing at all on Rakudo: no exception,';
say 'no warning, no elements. On Raku++ it runs once with $_ bound to the';
say 'object itself. Neither is what you meant.';
say '';
say 'the two working idioms:';
say '  positional slice : ', $a[1 .. $a.elems].raku;
say '  the public .arr  : ', $a.arr[1 .. *].raku, '   (index 0 is the -1 sentinel)';
say '';
say '.list gives you an undefined List type object on both engines,';
say 'and .map dies on Rakudo. Do not reach for either.';
```

```output
it claims to do Iterable : True

so a guard that checks for iterability passes — and then
`for $a { … }` quietly does nothing at all on Rakudo: no exception,
no warning, no elements. On Raku++ it runs once with $_ bound to the
object itself. Neither is what you meant.

the two working idioms:
  positional slice : ("a", "b", "c")
  the public .arr  : ("a", "b", "c")   (index 0 is the -1 sentinel)

.list gives you an undefined List type object on both engines,
and .map dies on Rakudo. Do not reach for either.
```

## Where the two engines differ

Exactly that `for` behaviour, plus one diagnostic timing: `KMP-Matcher('abc', 'b')`
with the wrong argument types is a compile-time refusal on Rakudo and a
run-time `X::Method::NotFound` on Raku++.

```raku name="portable"
use AlgorithmsIT :p1005, :p1006;
use AlgorithmsIT::Classes;

# always wrap the arguments, and always read the result as a slice
sub kmp(Str $text, Str $pattern) {
    KMP-Matcher(ArrayOneBased.new($text), ArrayOneBased.new($pattern)).List
}
say 'kmp("abababacaba", "ababaca") = ', kmp('abababacaba', 'ababaca').raku;
say '';
say 'two edges to guard against, identical on both engines:';
say '  an EMPTY pattern returns the spurious shift [1]:';
say '    ', kmp('abc', '').raku;
say '  and Compute-Prefix-Function on an empty pattern returns [0]:';
say '    ', Compute-Prefix-Function(ArrayOneBased.new('')).gist;
say '';
say 'the matcher compares with eq/ne, so elements compare as STRINGS —';
say '2.0 matches 2 and "01" does not match 1. For text that is exactly';
say 'what you want; for numeric data it is not.';
```

```output
kmp("abababacaba", "ababaca") = (2,)

two edges to guard against, identical on both engines:
  an EMPTY pattern returns the spurious shift [1]:
    (1,)
  and Compute-Prefix-Function on an empty pattern returns [0]:
    [ 0 ]

the matcher compares with eq/ne, so elements compare as STRINGS —
2.0 matches 2 and "01" does not match 1. For text that is exactly
what you want; for numeric data it is not.
```
