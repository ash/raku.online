---
name: Shell::Command
version: 1.2
auth: zef:raku-community-modules
kind: Distribution · files
summary: cp -r, rm -rf, mkpath, cat and which as portable Raku subs — the
  shell one-liners your script was about to shell out for, without the
  shell.
status: full
license: MIT
depends: File::Find
suite: 1 file, green
tested: 2026-08-28
raku-land: https://raku.land/zef:raku-community-modules/Shell::Command
source: https://github.com/raku-community-modules/Shell-Command
---

## What it is for

Every build script reaches a line where the author thinks "this is just
`cp -r`" — and then either shells out (goodbye Windows, hello quoting
bugs) or writes a recursive copy by hand. This module is the middle path:
the famous shell verbs as plain Raku subs that walk the filesystem
through Raku's own IO, so they behave the same everywhere Raku runs:

```raku name="cp-and-rm"
use Shell::Command;

my $work = $*TMPDIR.add("sc-demo-$*PID").Str;
mkpath "$work/src/deep";
"$work/src/a.txt".IO.spurt('first');
"$work/src/deep/b.txt".IO.spurt('second');

cp "$work/src", "$work/backup", :r;
say "$work/backup/deep/b.txt".IO.slurp;

rm_rf $work;
say $work.IO.e;
```

```output
second
False
```

`mkpath` is `mkdir -p`; `cp` copies one file, or with `:r` a whole tree —
creating the destination directories as it goes; `rm_rf` takes the tree
down again, files and all, and does not blink at a path that is already
gone. The names keep their shell spelling, underscores and all, so the
line reads like what it does.

## The rest of the toolbox

Three more verbs round it out. `rm_f` unlinks files (no directories, no
error if absent); `cat` prints files in order — the workhorse for
concatenating build fragments; and `which` walks `PATH` for an
executable:

```raku name="cat-and-which"
use Shell::Command;

my $work = $*TMPDIR.add("sc-cat-$*PID").Str;
mkpath $work;
"$work/one.txt".IO.spurt('line one');
"$work/two.txt".IO.spurt('line two');

cat "$work/one.txt", "$work/two.txt";

say which('sh');
rm_rf $work;
```

```output
line one
line two
/bin/sh
```

One habit to know: `cat` prints each file with `say`, so a file that
already ends in a newline gets a blank line after it — the files above
deliberately do not, and for byte-exact concatenation you would `print`
the slurps yourself.

If `which` is the main thing you came for, the dedicated
[File::Which](/modules/file-which/) distribution does that one job with
more care — `:all` results, Windows `PATHEXT` handling — where this
`which` is the simple Unix walk. The overlap is honest: this module is a
toolbox, that one is a tool.

There is also `run-command`, a thin wrapper over `run` that invokes an
external program portably — on Windows it routes through `cmd.exe` for
you — and hands back the `Proc`. It is the escape hatch for the verb
this module does not have.

## Where the two engines differ

Nothing on this page. The tree copy, the recursive removal, path
creation, concatenation and the PATH walk answer identically under
Raku++ and Rakudo — File::Find, which powers the recursion and has
[a page of its own](/modules/file-find/), already made the same claim.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Shell::Command`, which brings
   `File::Find` with it.
3. **Test** — the distribution's own suite: 1 file, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

Twelve distributions depend on it — mostly build tooling, which is
exactly the code that cannot afford to assume a shell.
