---
name: IO::Path::Dirstack
version: 0.1.1
auth: none stated
kind: Distribution · filesystem
summary: A shell-style directory stack — pushd changes the working directory
  and remembers where you were, popd goes back.
status: full
suite: 2 files, green
tested: 2026-09-15
license: GPL-3.0
depends: none beyond the core
raku-land: https://raku.land/?/IO::Path::Dirstack
source: none stated
---

## What it is for

A build script that has to run three commands in three different directories
either passes `:cwd` to every one of them or changes directory and changes
back. The second is shorter to write and easy to get wrong, because "changes
back" means remembering where you were.

`pushd` and `popd` are the shell's answer, and this distribution is the same
two routines for Raku.

## Pushing and popping

```raku name="pushd"
use IO::Path::Dirstack;

my $base = $*TMPDIR.add("ds-{$*PID}");
$base.add('a/b').mkdir;
LEAVE { run 'rm', '-rf', $base.Str }

my $start = $*CWD;

say 'pushd a   : ', pushd $base.add('a');
say '  now in  : ', $*CWD.basename;
say 'pushd a/b : ', pushd $base.add('a/b');
say '  now in  : ', $*CWD.basename;
say '';
say 'popd      : ', popd();
say '  now in  : ', $*CWD.basename;
say 'popd      : ', popd();
say '  back at the start : ', $*CWD.absolute eq $start.absolute;
```

```output
pushd a   : True
  now in  : a
pushd a/b : True
  now in  : b

popd      : True
  now in  : a
popd      : True
  back at the start : True
```

`pushd` takes either a `Str` or an `IO::Path`. Both routines return `True` on
success.

## The stack is process-global

```raku name="global"
use IO::Path::Dirstack;

my $base = $*TMPDIR.add("ds2-{$*PID}");
$base.add('a').mkdir;
LEAVE { run 'rm', '-rf', $base.Str }

my $start = $*CWD;

sub go-somewhere { pushd $base.add('a') }
sub come-back    { popd() }

go-somewhere();
say 'a sub pushed, and the change is visible out here : ', $*CWD.basename;
come-back();
say 'another sub popped, and we are back              : ', $*CWD.absolute eq $start.absolute;
```

```output
a sub pushed, and the change is visible out here : a
another sub popped, and we are back              : True
```

The stack is a file-scoped array — one per process, not an object you
instantiate — so a push in one routine is popped by another. Convenient for a
script; not thread-safe, and not something to use inside a library that a
caller might invoke concurrently.

## The one thing to know

A failed `pushd` returns an unthrown `Failure` instead of throwing, and pushes
nothing — so the stack silently desynchronises from what your code believes.

```raku name="failure-trap"
use IO::Path::Dirstack;

my $base = $*TMPDIR.add("ds3-{$*PID}");
$base.add('a').mkdir;
$base.add('f.txt').spurt('x');
LEAVE { run 'rm', '-rf', $base.Str }

my $start = $*CWD.absolute;

my $r = pushd $base.add('nope');
say 'pushd to a missing path:';
say '  it threw            : ', False;
say '  the directory moved : ', $*CWD.absolute ne $start;
say '';
my $r2 = pushd $base.add('f.txt');
say 'pushd to a plain file:';
say '  the directory moved : ', $*CWD.absolute ne $start;
say '';
say 'now push once successfully, and pop once:';
pushd $base.add('a');
say '  moved : ', $*CWD.absolute ne $start;
popd();
say '  back  : ', $*CWD.absolute eq $start;
say '';
say 'the stack is now empty, even though pushd was called three times';
```

```output
pushd to a missing path:
  it threw            : False
  the directory moved : False

pushd to a plain file:
  the directory moved : False

now push once successfully, and pop once:
  moved : True
  back  : True

the stack is now empty, even though pushd was called three times
```

In a `pushd … ; work() ; popd` block written without checking the return
value, the `popd` unwinds one level too far — or throws on an empty stack,
which is the other half of the problem.

Both routines are declared `--> Bool` and neither honours it on the failure
path. Test the return value, or check `.d` on the target yourself first.

## Where the two engines differ

On what `popd` throws when the stack is empty, and the Raku++ message is
actively misleading.

Rakudo raises `X::Cannot::Empty: Cannot pop from an empty Array[IO::Path]`,
which names the problem. Raku++ raises `X::TypeCheck::Assignment: Type check
failed for an element of the container; expected IO::Path but got Failure` —
a *secondary* failure from pushing the popped `Failure` back into the typed
array, naming neither the real problem nor the real line.

The failed-`pushd` return value differs the same way: `False`-ish on Raku++, a
`Failure` carrying `X::IO::Chdir` on Rakudo. Rakudo's at least tells you
whether the path was missing or was not a directory.

The distribution states no source repository in its metadata.
