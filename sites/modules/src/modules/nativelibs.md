---
name: NativeLibs
version: 0.0.9
auth: zef:raku-community-modules
kind: Distribution · native interface
summary: Open a shared library by name, resolve symbols out of it, and probe
  which ABI version exists at run time — with two distributions of this name
  installed.
status: divergent
suite: 4 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/NativeLibs
source: https://github.com/raku-community-modules/NativeLibs.git
---

## What it is for

`is native('foo')` needs a library name at compile time, and the name is
version-dependent: `libfoo.so.5` on one machine, `libfoo.so.6` on another.
This distribution lets you probe at run time — open candidates in turn until
one resolves a symbol you know — and gives you the library-name conventions
for each platform.

## Naming a library

```raku name="cannon"
use NativeLibs;

say 'is-win : ', NativeLibs::is-win;
say '';
for 'm', 'ssl', 'foo.so' -> $lib {
    say sprintf('  cannon-name(%-8s)          = %s', $lib.raku,
                NativeLibs::cannon-name($lib));
}
say '  cannon-name("m", v6)           = ', NativeLibs::cannon-name('m', v6);
say '  cannon-name("m", "6")          = ', NativeLibs::cannon-name('m', '6');
say '';
say 'a name that already carries an extension is passed through untouched,';
say 'so cannon-name will not version a path you resolved yourself.';
```

```output
is-win : False

  cannon-name("m"     )          = libm.dylib
  cannon-name("ssl"   )          = libssl.dylib
  cannon-name("foo.so")          = foo.so
  cannon-name("m", v6)           = libm.6.dylib
  cannon-name("m", "6")          = libm.6.dylib

a name that already carries an extension is passed through untouched,
so cannon-name will not version a path you resolved yourself.
```

## Opening and resolving

```raku name="loader"
use NativeLibs;

my $lib = NativeLibs::Loader.load(NativeLibs::cannon-name('m'));
say 'loaded : ', $lib.defined;
say '  name : ', $lib.name;
say '';
my $cos = $lib.symbol('cos');
say 'symbol("cos") : a Pointer, non-null : ', (+$cos != 0);
say '';
say 'disposing closes it:';
say '  dispose      : ', $lib.dispose.so;
say '';
my $missing = NativeLibs::Loader.load('libdefinitely-not-here');
say 'a library that does not exist : ',
    $missing ~~ Failure ?? 'a Failure' !! $missing.raku;
```

```output
loaded : True
  name : libm.dylib

symbol("cos") : a Pointer, non-null : True

disposing closes it:
  dispose      : True

a library that does not exist : a Failure
```

## Probing for the right ABI version

```raku name="searcher"
use NativeLibs;

say 'try-versions opens each candidate in turn and returns the first whose';
say 'name resolves the well-known symbol you name:';
say '  try-versions("m", "cos")       = ',
    NativeLibs::Searcher.try-versions('m', 'cos').raku;
say '  try-versions("m", "cos", 6, 5) = ',
    NativeLibs::Searcher.try-versions('m', 'cos', 6, 5).raku;
say '  try-versions("zzznope", "cos") = ',
    NativeLibs::Searcher.try-versions('zzznope', 'cos').defined
        ?? 'a name' !! 'undefined';
say '';
say 'at-runtime wraps that in a Block you can hand to `is native`:';
my &name = NativeLibs::Searcher.at-runtime('m', 'cos');
say '  at-runtime("m", "cos").()      = ', name().raku;
say '';
say 'note what happens when nothing is found: at-runtime returns the BARE';
say 'library name rather than failing, deliberately, so that NativeCall';
say 'dies later with its own message:';
my &nope = NativeLibs::Searcher.at-runtime('zzznope', 'cos');
say '  at-runtime("zzznope", "cos").() = ', nope().raku;
say '';
say 'so your `is native(…)` will fail at the first CALL, not at load, and';
say 'the message will be NativeCall`s rather than "cannot locate library".';
```

```output
try-versions opens each candidate in turn and returns the first whose
name resolves the well-known symbol you name:
  try-versions("m", "cos")       = "libm.dylib"
  try-versions("m", "cos", 6, 5) = Any
  try-versions("zzznope", "cos") = undefined

at-runtime wraps that in a Block you can hand to `is native`:
  at-runtime("m", "cos").()      = "libm.dylib"

note what happens when nothing is found: at-runtime returns the BARE
library name rather than failing, deliberately, so that NativeCall
dies later with its own message:
  at-runtime("zzznope", "cos").() = "zzznope"

so your `is native(…)` will fail at the first CALL, not at load, and
the message will be NativeCall`s rather than "cannot locate library".
```

## The one thing to know

Two distributions are called `NativeLibs`, both version 0.0.9, and `use
NativeLibs` resolves to a different one on each engine.

```raku name="which"
use NativeLibs;

say 'the tie between two same-version distributions is broken differently:';
say '';
say '  Raku++ loads zef:raku-community-modules (lib/NativeLibs.rakumod)';
say '  Rakudo loads github:salortiz            (lib/NativeLibs.pm6)';
say '';
say 'the two sources are near-identical, mostly reformatting. The one real';
say 'code difference is a signature:';
say '';
say '  community-modules : multi cannon-name(Str:D $libname, Version $version?)';
say '  salortiz          : multi cannon-name(Str $libname, Version $version = Version)';
say '';
say 'so the first undefined library name you pass behaves differently.';
say 'Pin the auth in your `use` if you care which one you get:';
say '  use NativeLibs:auth<zef:raku-community-modules>;';
say '';
say 'and note the module re-exports the whole of NativeCall, so';
say '`use NativeLibs` alone gives you is native, Pointer, CArray and';
say 'nativecast.';
```

```output
the tie between two same-version distributions is broken differently:

  Raku++ loads zef:raku-community-modules (lib/NativeLibs.rakumod)
  Rakudo loads github:salortiz            (lib/NativeLibs.pm6)

the two sources are near-identical, mostly reformatting. The one real
code difference is a signature:

  community-modules : multi cannon-name(Str:D $libname, Version $version?)
  salortiz          : multi cannon-name(Str $libname, Version $version = Version)

so the first undefined library name you pass behaves differently.
Pin the auth in your `use` if you care which one you get:
  use NativeLibs:auth<zef:raku-community-modules>;

and note the module re-exports the whole of NativeCall, so
`use NativeLibs` alone gives you is native, Pointer, CArray and
nativecast.
```

## Where the two engines differ

Beyond which distribution loads: `Loader.symbol` never reports "not found"
under Raku++ — it hands back a *defined* `Pointer` whose value is 0, where
Rakudo returns a `Failure`.

```raku name="portable"
use NativeLibs;

my $lib = NativeLibs::Loader.load(NativeLibs::cannon-name('m'));
say 'check the pointer, not the Failure:';
for 'cos', 'no_such_symbol_xyz' -> $sym {
    my $p = $lib.symbol($sym);
    my $ok = $p.defined && +$p != 0;
    say sprintf('  symbol(%-20s) usable ? %s', $sym.raku, $ok);
}
$lib.dispose;
say '';
say 'that `$p.defined && +$p != 0` test is the portable one — on Rakudo';
say 'the second row is a Failure and on Raku++ it is a null Pointer, and';
say 'both fail the test.';
say '';
say 'two more engine notes. $*VM.config<nativecall_backend> is ABSENT under';
say 'Raku++, so the module`s dyncall check compares an undefined value and';
say 'silently takes the libffi branch — which is the right branch here.';
say 'And Compile.compile-all links with $*VM.config<ldlibs>, which names';
say 'MoarVM`s own build-time libraries under Rakudo and is empty under';
say 'Raku++ — so the same build succeeds on one engine and fails on the';
say 'other for reasons that have nothing to do with your C.';
```

```output
check the pointer, not the Failure:
  symbol("cos"               ) usable ? True
  symbol("no_such_symbol_xyz") usable ? False

that `$p.defined && +$p != 0` test is the portable one — on Rakudo
the second row is a Failure and on Raku++ it is a null Pointer, and
both fail the test.

two more engine notes. $*VM.config<nativecall_backend> is ABSENT under
Raku++, so the module`s dyncall check compares an undefined value and
silently takes the libffi branch — which is the right branch here.
And Compile.compile-all links with $*VM.config<ldlibs>, which names
MoarVM`s own build-time libraries under Rakudo and is empty under
Raku++ — so the same build succeeds on one engine and fails on the
other for reasons that have nothing to do with your C.
```
