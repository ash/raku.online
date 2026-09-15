---
name: Trap
version: 0.0.5
auth: zef:lizmat
kind: Distribution · testing
summary: A class that impersonates an output handle well enough for print, say
  and printf, and keeps what was written instead of sending it anywhere.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/Trap
source: https://github.com/lizmat/Trap.git
---

## What it is for

Testing a routine that prints means capturing what it printed. Redirecting a
real file handle and reading it back is several lines and a temporary file;
what you want is an object that says "yes, I am `$*OUT`" and remembers.

This distribution is that object, with a `:tee` option for when you want to
capture the output *and* still see it.

## Capturing output

```raku name="trap"
use Trap;

my ($text, $silent);
{
    my $*OUT;                # scope the replacement
    Trap($*OUT);             # $*OUT is now a Trap instance
    say 'first line';
    print 'no newline';
    say '';
    printf("%s=%d\n", 'n', 42);
    $text   = $*OUT.text;
    $silent = $*OUT.silent;
}
say 'nothing leaked above this line';
say 'captured : ', $text.raku;
say 'silent   : ', $silent;
say '.text returns a : ', $text.^name;
```

```output
nothing leaked above this line
captured : "first line\nno newline\nn=42\n"
silent   : False
.text returns a : Str
```

The idiom is two statements: declare `my $*OUT` to scope the replacement, then
call the class itself on it. `Trap` has a `CALL-ME`, so `Trap($*OUT)` reads
like a function and installs the instance.

`.silent` is `True` while nothing has been recorded — useful for asserting
that a quiet path really was quiet.

## Both handles at once

```raku name="both"
use Trap;

my ($same, $both);
{
    my $*OUT;
    my $*ERR;
    Trap($*OUT, $*ERR);
    say  'to out';
    note 'to err';
    $same = $*OUT === $*ERR;
    $both = $*OUT.text;
}
say 'both handles are literally the same object : ', $same;
say 'interleaved text : ', $both.raku;
```

```output
both handles are literally the same object : True
interleaved text : "to out\nto err\n"
```

Two-handle mode gives you **one** object, so out and err are interleaved in
`.text` with nothing to tell them apart. If you need to distinguish them, trap
them separately.

## The one thing to know

A `Trap` is not an `IO::Handle`, and it implements exactly three methods.

```raku name="not-a-handle"
use Trap;

my @missing;
{
    my $*OUT;
    Trap($*OUT);
    for <flush write t lines slurp encoding> -> $m {
        @missing.push($m) unless $*OUT.^can($m);
    }
}
note 'methods a real handle has that Trap lacks : ', @missing.join(' ');
note 'Trap does IO::Handle : ', Trap ~~ IO::Handle;
note '';
my $e = 'no error';
{ my $*OUT; Trap($*OUT); try { my $x = $*OUT.t; CATCH { default { $e = .^name } } } }
note '$*OUT.t inside a trap -> ', $e;
```

```output

```

`.t` is the near-universal "am I attached to a terminal?" test that every
colour-aware library runs before deciding whether to emit escapes. Wrapping
such a library in a `Trap` replaces its output with a crash rather than
capturing it.

A second thing in the same area, and it is process-wide: `Trap($*OUT)` written
**without** a preceding `my $*OUT` replaces `PROCESS::<$OUT>` for the whole
program, and the class has no `restore`.

## Where the two engines differ

On `:tee<OUT>`, the module's headline convenience — and it is an engine bug
rather than a module one.

Under Raku++, a lexical `my $*OUT` in the same scope shadows
`PROCESS::{'$OUT'}` as well as the dynamic variable, so the tee target comes
back undefined and the teed copy is silently lost. `PROCESS::{'$ERR'}` is
unaffected, and a `my $*FOO` in the same position does not do it, so the
shadowing is specific to that one pairing. Under Rakudo the tee works and the
line appears on the terminal as well as in `.text`.

Teeing to a **file** is unaffected on Rakudo and hits the same shadowing on
Raku++; teeing to `ERR` works on both. So `:tee` is portable only for `ERR`
and, on one engine, not at all.

Two smaller notes, identical on both engines. An unusable tee target dies at
construction with `'42' cannot be used to tee`, which is the right time for
it. And `$*OUT.^name` is `FileHandle` under Raku++ and `IO::Handle` under
Rakudo, so keep that out of anything you assert on.
