---
name: File::Stat
version: 1.0.3
auth: zef:elcaro
kind: Distribution · files
summary: The raw `stat(2)` fields an IO::Path does not expose — inode,
  device, mode bits, link count, block counts, owner and group — as a live
  query against a path.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: Exportable
raku-land: https://raku.land/zef:elcaro/File::Stat
source: https://github.com/0racle/raku-File-Stat
---

## What it is for

`IO::Path` answers the questions most programs ask of a file — does it
exist, how big is it, when was it modified — and stops there. The rest of
the `stat` structure is what you need when the question is about the file
system rather than the file: is this the same file as that one, reached by
another name, which is an inode and device comparison; how much disk does
it really occupy, which is blocks rather than bytes; how many hard links
point at it; who owns it and with which permission bits.

This distribution exposes those fields, and the `lstat` variant that
describes a symbolic link instead of following it.

## The fields

```raku name="fields"
use File::Stat;

my $file = $*TMPDIR.add("stat-{$*PID}.bin");
$file.spurt('0123456789');
$file.chmod(0o640);

my $s = File::Stat.new(path => $file.Str);
say 'size    ', $s.size;
say 'mode    ', $s.mode.base(8);
say 'nlink   ', $s.nlink;
say 'blksize ', $s.blksize;
say 'inode   ', $s.ino > 0;
say 'device  ', $s.dev > 0;
say 'rdev    ', $s.rdev;
say 'owned   ', $s.uid == +$*USER;
say 'mtime   ', $s.mtime.^name;

$file.unlink;
```

```output
size    10
mode    100640
nlink   1
blksize 4096
inode   True
device  True
rdev    0
owned   True
mtime   Int
```

`mode` is the permission bits with the file type folded in, which is why
`100640` in octal rather than `640`. The timestamps are plain epoch
integers, not `DateTime`s, so turning one into a date is
`DateTime.new($s.mtime)`.

The `lstat` variant reports the link itself rather than what it points at,
which is how you tell them apart:

```raku name="symlinks"
use File::Stat;

my $dir = $*TMPDIR.add("statl-{$*PID}");
$dir.mkdir;
my $target = $dir.add('target.txt');
$target.spurt('0123456789abcdef');
my $link = $dir.add('thelink');
$target.symlink($link);

my $follow = File::Stat.new(path => $link.Str);
my $itself = File::Stat.new(path => $link.Str, l => True);
say 'follows the link: size ', $follow.size, ' mode ', $follow.mode.base(8);
say 'the link itself : mode ', $itself.mode.base(8);
say 'same inode      : ', $follow.ino == $itself.ino;

.unlink for $dir.dir;
$dir.rmdir;
```

```output
follows the link: size 16 mode 100644
the link itself : mode 120755
same inode      : False
```

## The one thing to know

The object caches nothing. Every accessor issues its own system call, so
the "snapshot" changes underneath you and can start throwing after it has
been working:

```raku name="not-a-snapshot"
use File::Stat;

my $file = $*TMPDIR.add("statg-{$*PID}.txt");
$file.spurt('aaaa');

my $s = File::Stat.new(path => $file.Str);
say $s.size;
$file.spurt('aaaabbbbcccc');
say $s.size;

$file.unlink;
say (try $s.size) // 'the file is gone, and so is every field';
```

```output
4
12
the file is gone, and so is every field
```

Two consequences most people miss. Reading all thirteen fields costs
thirteen system calls, and they are not guaranteed to agree with each
other — a file changed halfway through gives you a record that never
existed on disk at any instant. And an object built for a path that does
not exist constructs happily and fails only at the first field you ask for.
If you need a consistent record, read the fields once into your own
variables and work from those.

The other thing to know is how to reach the module at all. It marks two
subs, `stat` and `lstat`, with the `Exportable` distribution's trait, and
the two engines disagree about what that trait delivers: Raku++ exports
them on a plain `use` and refuses the tag form, Rakudo does the opposite.
`File::Stat.new(path => …)` is the spelling that works on both, and it is
what every example here uses.
