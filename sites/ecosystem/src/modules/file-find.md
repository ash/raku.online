---
name: File::Find
version: 0.2.5
auth: zef:raku-community-modules
kind: Distribution · files
summary: Walk a directory tree as a lazy sequence, filtered by name, type or
  path, without writing the recursion yourself.
status: full
license: MIT
suite: 1 file, green
tested: 2026-08-24
raku-land: https://raku.land/zef:raku-community-modules/File::Find
source: https://github.com/raku-community-modules/File-Find
---

## What it is for

`dir()` gives you one directory. Everything below it is your problem — a
recursive sub, a stack, a check for whether each entry is itself a directory,
and the bug where a symlink loop hangs you. `find` is that walk, already
written, and it hands back a lazy `Seq`:

```raku name="tour"
use File::Find;

my $root = $*TMPDIR.add("find-demo-$*PID");
LEAVE { run 'rm', '-rf', ~$root }
$root.add('src/deep').mkdir;
$root.add('README.md').spurt('readme');
$root.add('src/a.raku').spurt('say 1');
$root.add('src/deep/b.raku').spurt('say 2');

say find(dir => $root).elems;
say find(dir => $root, name => /\.raku$/).map(*.basename).sort.join(' ');
say find(dir => $root, type => 'dir').map(*.basename).sort.join(' ');
```

```output
5
a.raku b.raku
deep src
```

Five entries: two directories and three files. `find` yields directories as
well as files, which is why `type` exists.

## The filters

Every named argument is optional and they compose. `name` matches the
**basename**, `path` matches the whole path, `type` is `'file'`, `'dir'` or
`'symlink'`, and `exclude` prunes. Each takes a `Regex`, a `Str`, or a
`Callable` — anything you can smartmatch against.

```raku name="filters"
use File::Find;

my $root = $*TMPDIR.add("find-excl-$*PID");
LEAVE { run 'rm', '-rf', ~$root }
$root.add('keep').mkdir;
$root.add('.git').mkdir;
$root.add('keep/a.txt').spurt('a');
$root.add('.git/objects').spurt('junk');

say find(dir => $root, exclude => /'.git'/).map(*.basename).sort.join(' ');
say find(dir => $root, recursive => False).map(*.basename).sort.join(' ');
```

```output
a.txt keep
.git keep
```

`exclude` prunes the whole subtree, not just the matching entry — that is the
difference between it and filtering the result with `.grep`, and it is what you
want for `.git`, `node_modules` and friends, because the point is not to
descend into them at all.

`recursive => False` turns the walk into a single directory listing, which is
occasionally what you want when the rest of your filter logic is already
written against `find`.

## It is lazy, and that matters

The return value is a `Seq`, produced as you consume it. On a large tree that
is the difference between waiting and not:

```raku name="lazy"
use File::Find;

my $root = $*TMPDIR.add("find-lazy-$*PID");
LEAVE { run 'rm', '-rf', ~$root }
$root.mkdir;
$root.add("f$_.txt").spurt('x') for ^50;

my $seq = find(dir => $root);
say $seq.^name;
say $seq.head(3).elems;
say find(dir => $root, name => /f1 \d '.txt'/).elems;
```

```output
Seq
3
10
```

`.head(3)` stopped the walk after three entries. Being a `Seq`, it is also
one-shot: consume it twice and the second consumption throws. If you need the
list twice, `.list` it once and keep that.

Every element is an `IO::Path`, so `.basename`, `.extension`, `.slurp` and
`.modified` are all right there.

## Where the two engines differ

Nothing on this page. Every example prints the same bytes under Raku++ and
under Rakudo, twice on each.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install File::Find`, no dependencies to pull.
3. **Test** — the distribution's own suite: 1 file, 29 assertions, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

Three gaps stood between Raku++ and this suite, and the middle one is the sort
of bug that flatters an engine rather than failing it. `symlink` and `link`
existed only as methods, not as the subs the suite calls. Then `symlink` was
not absolutizing its target — the OS reads a relative link target relative to
the *link's* directory, not the current one, so the suite's
`symlink("t/dir1/another_dir", "t/dir2/symdir")` made a dangling link, the
whole symlink section quietly took its "this platform cannot" branch, and four
tests passed without testing anything. And the `X::IO` exception family could
be *thrown* by the engine's own IO builtins but not **constructed** by a
program, so the suite's way of mocking a directory error —
`X::IO::Dir.new(path => …, os-error => …).throw` — died. All thirteen of those
classes now exist and compose Rakudo's message text.
