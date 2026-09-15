---
name: Git::Status
version: 0.0.4
auth: zef:lizmat
kind: Distribution · git
summary: Run git status in a directory and present the porcelain output as
  seven typed lists plus a clean flag, read once at construction.
status: partial
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/Git::Status
source: https://github.com/lizmat/Git-Status.git
---

## What it is for

A release script wants one question answered before it does anything: is this
working tree clean? Shelling out to `git status --porcelain` and testing the
output for emptiness is three lines nobody writes the same way twice, and the
porcelain format has enough status letters to make "what exactly is dirty?"
a second, longer job.

This distribution answers both. It reads the porcelain output once, in
`TWEAK`, and exposes the result as a flag plus lists.

## Reading a repository

The example builds its own throwaway repository so the output is the same
everywhere:

```raku name="status"
use Git::Status;

my $repo = $*TMPDIR.add("gs-{$*PID}");
$repo.mkdir;
LEAVE { run 'rm', '-rf', $repo.Str }

run 'git', 'init', '-q', $repo.Str, :out, :err;
run 'git', '-C', $repo.Str, 'config', 'user.email', 'f@example.invalid';
run 'git', '-C', $repo.Str, 'config', 'user.name',  'Fixture';
$repo.add('tracked.txt').spurt("one\n");
$repo.add('todelete.txt').spurt("two\n");
run 'git', '-C', $repo.Str, 'add', '.', :out, :err;
run 'git', '-C', $repo.Str, 'commit', '-qm', 'first', :out, :err;

say 'a clean tree:';
my $clean = Git::Status.new(directory => $repo.Str);
say '  is-clean : ', $clean.is-clean;
say '  gist     : ', $clean.gist.raku;

$repo.add('tracked.txt').spurt("one\nchanged\n");
$repo.add('untracked.txt').spurt("three\n");
run 'git', '-C', $repo.Str, 'rm', '-q', 'todelete.txt', :out, :err;

say '';
say 'after changing, adding and removing a file:';
my $st = Git::Status.new(directory => $repo.Str);
say '  is-clean  : ', $st.is-clean;
say '  modified  : ', $st.modified.sort.join(' ');
say '  deleted   : ', $st.deleted.sort.join(' ');
say '  untracked : ', $st.untracked.sort.join(' ');
```

```output
a clean tree:
  is-clean : True
  gist     : ""

after changing, adding and removing a file:
  is-clean  : False
  modified  : tracked.txt
  deleted   : todelete.txt
  untracked : untracked.txt
```

The `directory` attribute is `IO()`-coerced, so a `Str` is fine, and it
defaults to `$*CWD`. `.is-clean` is the `.so` of `.clean`; either will do.

## The gist

```raku name="gist"
use Git::Status;

my $repo = $*TMPDIR.add("gs2-{$*PID}");
$repo.mkdir;
LEAVE { run 'rm', '-rf', $repo.Str }

run 'git', 'init', '-q', $repo.Str, :out, :err;
run 'git', '-C', $repo.Str, 'config', 'user.email', 'f@example.invalid';
run 'git', '-C', $repo.Str, 'config', 'user.name',  'Fixture';
$repo.add('a.txt').spurt("x\n");
run 'git', '-C', $repo.Str, 'add', '.', :out, :err;
run 'git', '-C', $repo.Str, 'commit', '-qm', 'first', :out, :err;
$repo.add('a.txt').spurt("y\n");
$repo.add('b.txt').spurt("z\n");

say Git::Status.new(directory => $repo.Str).gist.subst($repo.Str, '<REPO>');
```

```output
Git::Status:
  <REPO>

Modified:
  a.txt

Untracked:
  b.txt
```

`.gist` is a ready-to-print summary and returns the **empty string** for a
clean repository — so `say $status` prints a blank line rather than anything
reassuring. Test `.is-clean` for that.

## The one thing to know

Four of the seven accessors are always empty. `.added`, `.renamed`, `.copied`
and `.updated` are wired up to nothing.

```raku name="added-trap"
use Git::Status;

my $repo = $*TMPDIR.add("gs3-{$*PID}");
$repo.mkdir;
LEAVE { run 'rm', '-rf', $repo.Str }

run 'git', 'init', '-q', $repo.Str, :out, :err;
run 'git', '-C', $repo.Str, 'config', 'user.email', 'f@example.invalid';
run 'git', '-C', $repo.Str, 'config', 'user.name',  'Fixture';
$repo.add('base.txt').spurt("x\n");
run 'git', '-C', $repo.Str, 'add', '.', :out, :err;
run 'git', '-C', $repo.Str, 'commit', '-qm', 'first', :out, :err;

$repo.add('staged-new.txt').spurt("new\n");
run 'git', '-C', $repo.Str, 'add', 'staged-new.txt', :out, :err;

my $porcelain = run('git', '-C', $repo.Str, 'status', '--porcelain', :out).out.slurp(:close);
say 'git itself reports : ', $porcelain.trim.raku;
my $st = Git::Status.new(directory => $repo.Str);
say 'clean flag flipped : ', !$st.is-clean;
say '.added reports     : ', $st.added.elems, ' entries';
say '.gist mentions it  : ', $st.gist.contains('staged-new') ?? 'yes' !! 'no';
```

```output
git itself reports : "A  staged-new.txt"
clean flag flipped : True
.added reports     : 0 entries
.gist mentions it  : no
```

In `TWEAK`, the branches for status letters `A`, `R`, `C` and `U` set the
clean flag to `False` and never push the path onto their array; only `M`, `D`
and `?` record anything. A newly staged file is therefore invisible to
everything except `.clean`, and the gist has no "Added:" section even though
the class contains the code to print one.

`.deleted` does pick up a staged deletion, so the asymmetry is a bug rather
than a decision about index versus worktree. Anyone writing "list the files
I've staged" against this gets a confident empty answer.

## Where the two engines differ

Only in `.raku` rendering. The accessors hand back an `array[str]`, which
Raku++ prints as `["tracked.txt"]` and Rakudo as
`array[str].new("tracked.txt")`. The values, the gist and the flags are
identical, which is why every example above joins rather than `.raku`s.

Three things that are not engine differences. The status is read **once, in
`TWEAK`** — the object is a snapshot, so change the repository and you must
build a new one. Any porcelain status character the class does not recognise
produces `note "Unrecognized: '$_'"` on **stderr**, from inside the
constructor, with no way to turn it off. And it parses git's v1 porcelain
format, in which a rename line is `XY ORIG -> PATH`; the whole `ORIG -> PATH`
string would land in the path slot, which is moot only because `.renamed` is
never populated.
