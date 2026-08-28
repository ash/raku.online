---
name: File::Directory::Tree
version: 0.2
auth: zef:raku-community-modules
kind: Distribution · files
summary: mkdir -p, rm -r and "empty this directory" as three Raku subs —
  the whole-tree operations the core deliberately leaves out.
status: full
license: Artistic-2.0
suite: 1 file, green
tested: 2026-08-28
raku-land: https://raku.land/zef:raku-community-modules/File::Directory::Tree
source: https://github.com/raku-community-modules/File-Directory-Tree
---

## What it is for

Core Raku gives you `mkdir` and `rmdir`, one level at a time, and `rmdir`
refuses a directory with anything in it. The shell verbs you actually
reach for — `mkdir -p`, `rm -r` — operate on **trees**, and this module is
those verbs: `mktree` creates a whole path of directories, `rmtree`
removes a directory with everything below it, and `empty-directory` clears
the contents while keeping the directory. Twenty distributions depend on
it; if you have used [File::Temp](/modules/file-temp/), its
cleaned-up-for-you `tempdir` is this module working.

```raku name="mktree-and-rmtree"
use File::Directory::Tree;

my $root = $*TMPDIR.add("fdt-demo-$*PID");
mktree $root.add('deep/deeper/deepest');
say $root.add('deep/deeper/deepest').d;

$root.add('deep/note.txt').spurt('hello');
say rmtree($root.add('deep'));
say $root.add('deep').e;
say $root.d;
rmtree $root;
say $root.e;
```

```output
True
True
False
True
False
```

Both subs take anything `Cool` that names a path — a string or an
`IO::Path` — and return `True` on success. `mktree` also takes
`:mask(0o700)` for the permissions of every directory it creates, which is
the polite way to make a private cache directory in one call.

## Emptying without removing

`empty-directory` is the third verb, for the log directory or spool whose
*existence* other code relies on — everything inside goes, including
subtrees, and the directory itself stays:

```raku name="empty-directory"
use File::Directory::Tree;

my $work = $*TMPDIR.add("fdt-empty-$*PID");
mktree $work.add('cache/a/b');
$work.add('cache/one.txt').spurt('x');
$work.add('cache/a/two.txt').spurt('y');

say empty-directory($work.add('cache'));
say $work.add('cache').d;
say $work.add('cache').dir.elems;
rmtree $work;
```

```output
True
True
0
```

Symlinks inside the tree are unlinked, not followed — a link out to
somewhere precious does not make `rmtree` delete the precious thing.

## What the edges do

The semantics at the edges are the ones that make scripts idempotent, and
they are worth knowing rather than guessing:

```raku name="edge-cases"
use File::Directory::Tree;

my $work = $*TMPDIR.add("fdt-edges-$*PID");
mktree $work;

say rmtree($work.add('never/existed'));

my $file = $work.add('plain.txt');
$file.spurt('z');
say rmtree($file).so;
say $file.e;

rmtree $work;
```

```output
True
False
True
```

Removing a tree that is not there is `True` — the state you asked for is
the state you have, so a cleanup path can run twice without guarding.
Pointing `rmtree` at a plain *file*, though, is a `Failure` — this module
removes directory trees, not files, and it will not quietly become `rm
-rf` for whatever it is handed. The file is untouched. (A `Failure` is
falsey but throws if used carelessly; `.so`, as here, or an `if`/`with`
disarms it.)

## Where the two engines differ

Nothing on this page. Tree creation, removal, the emptying, and both edge
behaviours answer identically under Raku++ and Rakudo.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install File::Directory::Tree`; it depends on
   nothing outside the core.
3. **Test** — the distribution's own suite: 1 file, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

Nothing had to be fixed anywhere — which for this module means recursive
directory walking, `unlink` vs `rmdir` dispatch, symlink detection with
`.l`, and `Failure` objects all agree between the engines. It earned the
quietest kind of page.
