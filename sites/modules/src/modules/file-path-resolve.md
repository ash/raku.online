---
name: File::Path::Resolve
version: 0.0.1
kind: Distribution · files
summary: A path string turned into an absolute IO::Path, with a leading
  tilde expanded to the home directory first and every `..` collapsed.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: Unlicense
raku-land: https://raku.land/?/File::Path::Resolve
source: https://github.com/atweiden/file-path-resolve
---

## What it is for

A path typed by a person, or read out of a configuration file, arrives in
whatever shape suited whoever wrote it: relative to somewhere, with a
tilde at the front, with `..` segments in the middle. Before the program
can compare it with another path, use it as a hash key or print it in a
diagnostic, it has to become one canonical absolute thing.

Raku's `.resolve` does most of that. It does not expand the tilde, because
the shell normally does that before a program sees it — and a path from a
config file never went through a shell. This distribution is the tilde
expansion plus `.resolve`, in one call.

## Resolving

```raku name="resolve"
use File::Path::Resolve;

my $R = File::Path::Resolve;
my $home = $*HOME.Str;

say $R.absolute('~').Str eq $home;
say $R.absolute('~/.config').Str eq "$home/.config";
say $R.absolute('~//.config').Str eq "$home/.config";
say $R.absolute('/tmp/../tmp').Str.ends-with('/tmp');
say $R.absolute('relative/bit').Str.starts-with($*CWD.Str);
say $R.absolute('~').^name;
say $R.absolute('/no/such/path').Str;
```

```output
True
True
True
True
True
IO::Path
/no/such/path
```

Everything comes back as an `IO::Path`, absolute, whether or not the path
exists — the last line is a path to nothing and resolves happily, which is
right, because you often want to canonicalise a name before creating it.

## The one thing to know

`relative($path, $base)` treats the base as a **file** and resolves against
its parent directory, so passing a directory silently discards that
directory:

```raku name="relative-base"
use File::Path::Resolve;

my $R = File::Path::Resolve;
my $root = $*TMPDIR.add("fpr-{$*PID}");
$root.mkdir;
$root.add('project').mkdir;
$root.add('project/sub').mkdir;
$root.add('project/conf.ini').spurt("k=v\n");
$root.add('project/sub/other.ini').spurt("k=v\n");

my $dir  = $root.add('project').Str;
my $file = $root.add('project/conf.ini').Str;

say 'base is the directory: ', $R.relative('sub/other.ini', $dir).e;
say 'base is a file in it : ', $R.relative('sub/other.ini', $file).e;

$root.add('project/sub/other.ini').unlink;
$root.add('project/conf.ini').unlink;
$root.add('project/sub').rmdir;
$root.add('project').rmdir;
$root.rmdir;
```

```output
base is the directory: False
base is a file in it : True
```

The first resolves to a path that does not exist, because `project` was
dropped on the way. The second finds the file. So the argument means "the
file whose neighbours you are resolving", not "the directory you are
resolving inside" — the opposite of what the name suggests, and a mistake
that produces a wrong path rather than an error.

If your base really is a directory, append a dummy file name to it, or just
use `$dir.IO.add($path)` and skip this method.

Two smaller things: `~username` is not expanded, so `~root` becomes a
relative path with a literal tilde in it, and an empty string throws a
constraint failure rather than returning anything.
