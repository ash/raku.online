---
name: P5reverse
version: 0.0.10
auth: zef:lizmat
kind: Distribution · Perl 5 compatibility
summary: Perl's `reverse` — which dispatches on the argument's type rather
  than on calling context, because Raku has no calling context.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5reverse
source: https://github.com/lizmat/P5reverse.git
---

## What it is for

Perl's `reverse` does two different things depending on context: in list
context it reverses the list, in scalar context it concatenates and reverses
the string. Raku has no calling context, so a port has to decide by something
else — and this distribution decides by the argument's type.

## Using it

```raku name="basics"
use P5reverse;

say 'a Str  : ', reverse('abc').raku;
say 'a List : ', reverse(('a', 'b', 'c')).raku;
say 'an Array : ', reverse([1, 2, 3]).raku;
my $none = try reverse();
say 'nothing  : ', $! ?? 'refused' !! $none.raku;
say '';
say 'three candidates, by type:';
say '  ()                       -> Nil';
say '  (List:D  --> List:D)     -> the list, reversed';
say '  (Str(Any) --> Str:D)     -> the string, reversed';
```

```output
a Str  : "cba"
a List : ("c", "b", "a")
an Array : (3, 2, 1)
nothing  : refused

three candidates, by type:
  ()                       -> Nil
  (List:D  --> List:D)     -> the list, reversed
  (Str(Any) --> Str:D)     -> the string, reversed
```

## The one thing to know

The decision is made by the *type of the argument*, not by what you do with
the result. A single Perl idiom therefore splits into two spellings.

```raku name="dispatch"
use P5reverse;

say 'Perl:   my $s = reverse "hello";     # scalar context: "olleh"';
say '        my @l = reverse "hello";     # list context:   ("hello")';
say '';
say 'here the argument decides:';
say '  reverse("hello")        = ', reverse('hello').raku;
say '  reverse(("hello",))     = ', reverse(('hello',)).raku;
say '';
say 'so a ported line that fed a LIST to reverse and used the result as a';
say 'string now gets a reversed list, and one that fed a single string and';
say 'wanted a one-element list gets a reversed string.';
say '';
say 'a number goes through the Str(Any) coercion:';
say '  reverse(1234)           = ', reverse(1234).raku;
say '';
say 'and the join-then-reverse idiom is explicit:';
my @words = <alpha beta gamma>;
say '  reverse(@words.join)    = ', reverse(@words.join).raku;
say '  reverse(@words.List)    = ', reverse(@words.List).raku;
```

```output
Perl:   my $s = reverse "hello";     # scalar context: "olleh"
        my @l = reverse "hello";     # list context:   ("hello")

here the argument decides:
  reverse("hello")        = "olleh"
  reverse(("hello",))     = ("hello",)

so a ported line that fed a LIST to reverse and used the result as a
string now gets a reversed list, and one that fed a single string and
wanted a one-element list gets a reversed string.

a number goes through the Str(Any) coercion:
  reverse(1234)           = "4321"

and the join-then-reverse idiom is explicit:
  reverse(@words.join)    = "ammagatebahpla"
  reverse(@words.List)    = ("gamma", "beta", "alpha")
```

## Where the two engines differ

Passing several arguments — Perl's `reverse @a, @b` — is refused by both, but
Rakudo refuses it at **compile time**, so no `try` can catch it.

```raku name="multi-arg"
use P5reverse;

say 'Perl`s `reverse $a, $b, $c` has no candidate here. Build the list:';
say '  reverse((1, 2, 3))          = ', reverse((1, 2, 3)).raku;
my @a = 1, 2;
my @b = 3, 4;
say '  reverse((|@a, |@b))         = ', reverse((|@a, |@b)).raku;
say '';
say 'the bare `reverse(1, 2, 3)` is "===SORRY!=== Calling reverse(Int,';
say 'Int, Int) will never work with any of these multi signatures" on';
say 'Rakudo, and a run-time dispatch failure on Raku++. Neither runs it.';
say '';
say 'core Raku`s own .reverse is the method form and takes no arguments';
say 'at all:';
say '  "abc".flip      = ', 'abc'.flip.raku, '   <- the Str one';
say '  (1, 2, 3).reverse = ', (1, 2, 3).reverse.raku, '  <- the List one';
say '';
say 'porting to those two is the end state; P5reverse is the step that';
say 'lets the rest of the file keep compiling in the meantime.';
```

```output
Perl`s `reverse $a, $b, $c` has no candidate here. Build the list:
  reverse((1, 2, 3))          = (3, 2, 1)
  reverse((|@a, |@b))         = (4, 3, 2, 1)

the bare `reverse(1, 2, 3)` is "===SORRY!=== Calling reverse(Int,
Int, Int) will never work with any of these multi signatures" on
Rakudo, and a run-time dispatch failure on Raku++. Neither runs it.

core Raku`s own .reverse is the method form and takes no arguments
at all:
  "abc".flip      = "cba"   <- the Str one
  (1, 2, 3).reverse = (3, 2, 1).Seq  <- the List one

porting to those two is the end state; P5reverse is the step that
lets the rest of the file keep compiling in the meantime.
```

The container type of a reversed `Array` differs cosmetically — `.raku`
renders it one way on each engine — so compare elements, not the rendering.
