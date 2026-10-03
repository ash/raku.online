---
title: Native pointers — NativeCall Pointer
slug: native-pointers
status: full
browser: false
browser-why: the WebAssembly engine has no NativeCall
order: 75
summary: A NativeCall Pointer is a number, its address — an Int you can add to, compare, and rebuild a pointer from.
---

`Pointer` comes from `use NativeCall` and holds a machine address — what C calls
a `void *`. Raku treats it as a **number**: numerically, a pointer is its
address, an `Int`. That is what makes pointer arithmetic possible without any
special operators.

These examples can't run in the browser playground, which has no NativeCall, so
they are shown with output verified against the interpreter and Rakudo at build
time.

## A pointer numifies to its address

Prefix `+` gives the address, and arithmetic on a pointer is arithmetic on that
address. The result is an `Int`, not a pointer and not a `Num`.

```raku
use NativeCall;
my $p = Pointer.new(4096);
say +$p;
say $p + 8;
say ($p + 8).^name;
say $p == 4096;
```
```output
4096
4104
Int
True
```

## Rebuilding a pointer from an address

`Pointer.new` takes an address, so stepping through native memory is a matter
of computing the next address and wrapping it again. `cmp` orders two pointers
by address, and `abs` gives an `Int` too.

```raku
use NativeCall;
my $p = Pointer.new(4096);
my $q = Pointer.new(+$p + 3 * 8);
say +$q;
say $p cmp $q;
say abs Pointer.new(-16);
```
```output
4120
Less
16
```

## NULL is defined but false

`Pointer.new` with no address is C's `NULL`. It is still a real object, so it is
**defined**; emptiness is what its truth value reports.

```raku
use NativeCall;
my $null = Pointer.new;
say $null.defined;
say so $null;
say so Pointer.new(64);
```
```output
True
False
True
```

## Where Raku++ excels

A pointer's number is an integer address, and addresses are ordered, as they
are in C. Raku++ lets a `Pointer` be a `Real`, so `<`, `<=`, `>`, `>=`, `<=>`,
`%`, `mod` and `%%` work on it directly. Rakudo's `Pointer` defines `.Numeric`
and `.Int` but no `.Real`, so each of those operators dies there
(*"Cannot resolve caller Real"*), even though `$p + 8`, `$p == $q` and
`$p cmp $q` all answer.

```raku
use NativeCall;
my $buf = Pointer.new(4096);
my $end = Pointer.new(4096 + 64);
say $buf < $end;      # Raku++: True   ·   Rakudo: dies
say $buf <=> $end;    # Raku++: Less   ·   Rakudo: dies
say $buf %% 16;       # Raku++: True   ·   Rakudo: dies
```

Code that must run on both engines compares the addresses instead:
`+$buf < +$end`.

## Notes

- Both engines show the address in hex in `.gist`, but they name the type
  differently (`Pointer<0x1000>` in Raku++, `NativeCall::Types::Pointer<0x1000>`
  in Rakudo), and `.Str` differs as well. Compare addresses with `+`, never
  through the string form.
- `Pointer[T]`, a typed pointer, numifies the same way: `+Pointer[int32].new(4096)`
  is `4096`, and adding to it gives an `Int` in bytes, not in elements.
