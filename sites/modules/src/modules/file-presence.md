---
name: File::Presence
version: 0.2.0
kind: Distribution · files
summary: Four compound questions about a path — does it exist and is it
  readable and is it a file — answered as one boolean each, with no
  exception when the path is not there.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: Unlicense
raku-land: https://raku.land/?/File::Presence
source: https://github.com/atweiden/file-presence
---

## What it is for

The check before opening a file is never one check. "Can I read this config
file" means it exists, and it is readable, and it is a file rather than a
directory — three tests whose order matters, because asking about
readability of something that is not there is a different kind of answer
than `False`.

Raku's own `.e`, `.r` and `.f` each answer one third of it, and on a
missing path some of them hand back a `Failure` that throws when you use
it. This distribution rolls each useful combination into one call that
always answers a plain `Bool`.

## The four questions

```raku name="questions"
use File::Presence;

my $dir = $*TMPDIR.add("pres-{$*PID}");
$dir.mkdir;
$dir.add('sub').mkdir;
my $file = $dir.add('readable.txt');
$file.spurt("hi\n");
$file.chmod(0o444);

my $P = File::Presence;
say 'file, readable       ', $P.exists-readable-file($file.Str);
say 'file, read-write     ', $P.exists-readwriteable-file($file.Str);
say 'dir, readable        ', $P.exists-readable-dir($dir.add('sub').Str);
say 'dir, read-write      ', $P.exists-readwriteable-dir($dir.add('sub').Str);
say 'missing              ', $P.exists-readable-file($dir.add('nope').Str);
say 'a dir asked as file  ', $P.exists-readable-file($dir.add('sub').Str);
say 'a file asked as dir  ', $P.exists-readable-dir($file.Str);

say $P.show($file.Str).sort.map({ .key ~ '=' ~ .value }).join(' ');

$file.chmod(0o644);
$file.unlink;
$dir.add('sub').rmdir;
$dir.rmdir;
```

```output
file, readable       True
file, read-write     False
dir, readable        True
dir, read-write      True
missing              False
a dir asked as file  False
a file asked as dir  False
d=False e=True f=True r=True w=False x=False
```

Nothing throws, everything is a `Bool`, and the file-versus-directory
distinction is honoured in both directions. `show` is the underlying
six-flag snapshot the four predicates are built from, for when you want to
ask a question the four do not cover.

## The one thing to know

A `False` never distinguishes "not there" from "there, but I cannot see
it". Every answer bottoms out in an existence test, and that test is
`False` for a file you lack permission to reach:

```raku name="indistinguishable"
use File::Presence;

my $dir = $*TMPDIR.add("presl-{$*PID}");
$dir.mkdir;
$dir.add('locked').mkdir;
$dir.add('locked/inside.txt').spurt("I exist\n");

my $P = File::Presence;
my $real    = $dir.add('locked/inside.txt').Str;
my $missing = $dir.add('locked/never-made.txt').Str;

say 'before: real    ', $P.exists-readable-file($real);
say 'before: missing ', $P.exists-readable-file($missing);

$dir.add('locked').chmod(0o000);
say 'after:  real    ', $P.exists-readable-file($real);
say 'after:  missing ', $P.exists-readable-file($missing);
say 'identical snapshots: ',
    $P.show($real).sort.gist eq $P.show($missing).sort.gist;

$dir.add('locked').chmod(0o755);
$dir.add('locked/inside.txt').unlink;
$dir.add('locked').rmdir;
$dir.rmdir;
```

```output
before: real    True
before: missing False
after:  real    False
after:  missing False
identical snapshots: True
```

With the parent directory unsearchable, a file that is certainly on disk
and a path that was never created produce byte-identical all-false answers.
So "this file does not exist, I will create it" is the wrong conclusion to
draw from a `False` — the create will fail with a permission error, and the
diagnostic you print will say the wrong thing.

Where that distinction matters, test the parent directory's own
searchability first, or attempt the open and read the error. A dangling
symbolic link collapses the same way, reporting as nothing at all rather
than as a link that points nowhere.
