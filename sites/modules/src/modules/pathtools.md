---
name: PathTools
version: 0.2.0
auth: github:ugexe
kind: Distribution · filesystem
summary: Five shell-flavoured filesystem helpers — list a tree, delete paths,
  create a directory chain, mint temporary paths — all Str in and Str out.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:ugexe/PathTools
source: https://github.com/ugexe/Raku-PathTools.git
---

## What it is for

`IO::Path` is the right abstraction and sometimes the long way round. When
what you want is "give me every file under here" or "make this whole chain of
directories", a sub that takes a string and returns strings is less ceremony
than composing `.dir`, `.d`, `.mkdir` and a recursion yourself.

This distribution is those five subs, with the switches spelled the way `ls`
and `rm` spell them.

## Listing and creating

```raku name="ls"
use PathTools;

my $root = "{$*TMPDIR}/pt-{$*PID}";
LEAVE { rm($root, :r, :d, :f) if $root.IO.e }

say 'mkdirs returns the deepest directory it made:';
my $deep = mkdirs("$root/a/b/c");
say '  ', $deep.subst($root, '<ROOT>');
say '  it exists : ', $deep.IO.d;

"$root/a/one.txt".IO.spurt('x');
"$root/a/b/two.txt".IO.spurt('y');
"$root/a/b/c/three.txt".IO.spurt('z');

sub show(@l) { @l.map(*.Str.subst($root, '<ROOT>')).sort.join("\n  ") }

say '';
say 'ls flat (files and directories):';
say '  ', show(ls("$root/a").list);
say 'ls recursive:';
say '  ', show(ls("$root/a", :r).list);
say 'ls recursive, directories only:';
say '  ', show(ls("$root/a", :r, :!f).list);
```

```output
mkdirs returns the deepest directory it made:
  <ROOT>/a/b/c
  it exists : True

ls flat (files and directories):
  <ROOT>/a/b
  <ROOT>/a/one.txt
ls recursive:
  <ROOT>/a/b
  <ROOT>/a/b/c
  <ROOT>/a/b/c/three.txt
  <ROOT>/a/b/two.txt
  <ROOT>/a/one.txt
ls recursive, directories only:
  <ROOT>/a/b
  <ROOT>/a/b/c
```

`:f` and `:d` say whether files and directories appear in the output, and `:r`
turns on recursion. Both default to `True`; `:r` defaults to `False`.

## Temporary paths

```raku name="mktemp"
use PathTools;

my $path = tmppath();
say 'tmppath mints a path without creating anything:';
say '  looks like a path : ', $path.IO.parent.d;
say '  it exists         : ', $path.IO.e;

my $dir  = mktemp();
my $file = mktemp(:f);
say '';
say 'mktemp creates:';
say '  directory exists : ', $dir.IO.d;
say '  file exists      : ', $file.IO.f;
```

```output
tmppath mints a path without creating anything:
  looks like a path : True
  it exists         : False

mktemp creates:
  directory exists : True
  file exists      : True
```

`tmppath` mints a name; `mktemp` creates a directory, or a file with `:f`.
Which brings us to the thing that is easy to miss: `mktemp` results are
**process-scoped**. An `END` block deletes both the directory and the file —
and anything you wrote into them — when the program exits. It is scratch space
for this run, not a path you own.

## The one thing to know

`ls(:r, :!d)` is not "all files, recursively". Suppressing directories from
the output suppresses the **recursion** as well.

```raku name="recursion-trap"
use PathTools;

my $root = "{$*TMPDIR}/pt2-{$*PID}";
LEAVE { rm($root, :r, :d, :f) if $root.IO.e }

mkdirs("$root/sub");
"$root/top.txt".IO.spurt('t');
"$root/sub/deep.txt".IO.spurt('d');

sub show(@l) { @l.map(*.Str.subst($root, '<ROOT>')).sort.join(' | ') }

say 'the nested file exists : ', "$root/sub/deep.txt".IO.e;
say 'ls(:r)          : ', show(ls($root, :r).list);
say 'ls(:r, :!d)     : ', show(ls($root, :r, :!d).list);
say '';
say 'the working incantation:';
say 'ls(:r).grep(*.IO.f) : ', show(ls($root, :r).grep(*.IO.f).list);
```

```output
the nested file exists : True
ls(:r)          : <ROOT>/sub | <ROOT>/sub/deep.txt | <ROOT>/top.txt
ls(:r, :!d)     : <ROOT>/top.txt

the working incantation:
ls(:r).grep(*.IO.f) : <ROOT>/sub/deep.txt | <ROOT>/top.txt
```

The recursive step is gated on the same `:d` flag that controls the output, so
asking not to *see* directories means never *entering* them. No error, no
warning — just a truncated list, and in a backup or checksum script, silently
missing every nested file.

Use `ls($path, :r).grep(*.IO.f)` instead.

## Where the two engines differ

On how loudly they refuse an inconsistency in the module's own return type.

`ls` returns a **list** when given a directory and a bare **`Str`** when given
a plain file. Rakudo catches that at the first `@`-sigilled binding —
`Type check failed in binding to parameter '@got'; expected Positional but got
Str` — while Raku++ binds the string as a one-element list and carries on. So
code that looks fine on Raku++ breaks on Rakudo. Normalise with
`my @l = ls($p) ~~ Positional ?? ls($p).list !! (ls($p),)` if the path might
be either.

One more thing that is not an engine difference: `rm` defaults `:d` to `True`
but leaves `:r` undefined, so `rm($dir)` on a non-empty directory attempts an
`rmdir`, fails inside a `try`, and reports nothing at all. Pass `:r`
explicitly when you mean recursive, as every `LEAVE` block above does.
