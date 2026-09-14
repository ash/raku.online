---
name: NativeHelpers::Array
version: 0.0.6
auth: zef:jonathanstowe
kind: Distribution · native
summary: Four subs that move data between a Raku Array or Buf and the
  CArray a C function wants — typed, sized and copied — so a NativeCall
  binding can hand a list to C and read one back without writing the loop
  each time.
status: full
suite: 3 files, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/zef:jonathanstowe/NativeHelpers::Array
source: https://github.com/jonathanstowe/NativeHelpers-Array
---

## What it is for

A C function that takes `int *values, size_t n` wants a `CArray[int32]`,
and a Raku program has an `Array`. The conversion is a loop, the loop is
five lines, and every binding writes it twice — once in and once out, with
the element count carried separately because a C array does not know its
own length. This distribution is those loops, written once, with the type
in the signature. Eleven distributions use it, mostly bindings to audio,
image and database libraries.

## The four copies

```raku name="copies"
use NativeCall;
use NativeHelpers::Array;

my $c = copy-to-carray([3, 1, 4, 1, 5], int32);
say $c.elems, ' ', $c[2], ' ', $c.of;
say copy-to-array($c, 5);
say copy-to-array($c, 3);

my $bytes = copy-buf-to-carray(Buf.new(72, 105, 33));
say $bytes.of, ' ', $bytes.elems;
say copy-carray-to-buf($bytes, 3).decode;
say copy-carray-to-buf($bytes, 2).decode;
```

```output
5 4 (int32)
[3 1 4 1 5]
[3 1 4]
(uint8) 3
Hi!
Hi
```

`copy-to-carray` takes the list and the native type — `int32`, `num64`,
`uint8`, any type a `CArray` can be parameterised with — and gives back a
freshly allocated `CArray` of that type. `copy-buf-to-carray` is the same
for a `Buf`, whose element type is already known to be a byte. The two
reverse subs take the count as their second argument, and that count is
the whole point of the API: it is *your* number, because a `CArray` that
came back from C has no idea how long it is. Ask for three of five and you
get three.

## The one thing to know

These are copies, and they are copies in both directions. `copy-to-carray`
allocates new native memory and fills it; writing into the `CArray` after
that does not change the Array it came from, and reading the Array back
with `copy-to-array` after C has written into the `CArray` is the only way
to see C's changes. That is the behaviour you want for a function that
reads its input, and a trap for one that fills a buffer *in place*: pass
the `CArray` itself, keep it, and copy out afterwards — the original Array
is not aliased and never will be.

The other thing to know is that `.^name` of a `CArray` differs between
engines (`CArray[int32]` here, `NativeCall::Types::CArray[int32]` under
Rakudo), which is why the example prints `.of` and `.elems` instead. The
values are the same; only the spelling of the type is not.
