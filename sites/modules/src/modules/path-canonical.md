---
name: Path::Canonical
version: *
auth: github:mattn
kind: Distribution · paths
summary: Collapses `.`, `//` and `..` in a path string — textually, never
  touching the filesystem, and always returning an absolute path.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/github:mattn/Path::Canonical
source: git://github.com/mattn/p6-Path-Canonical.git
---

## What it is for

Two path strings can name the same place and not compare equal: `/a/b/../c`
and `/a/c`, `/a//b` and `/a/b`. Tidying them into one spelling is what this
distribution does — as pure string surgery, with no `stat` and no symlink
resolution.

## Tidying

```raku name="basics"
use Path::Canonical;

for '/a/b/c', '/a/./b', '/a/b/../c', '/a//b', '///a/b',
    '/a/b/', '/a/b/.', '/a/b/..', '/..', '/' -> $p {
    say sprintf('  %-12s -> %s', $p.raku, canon-path($p).raku);
}
```

```output
  "/a/b/c"     -> "/a/b/c"
  "/a/./b"     -> "/a/b"
  "/a/b/../c"  -> "/a/c"
  "/a//b"      -> "/a/b"
  "///a/b"     -> "/a/b"
  "/a/b/"      -> "/a/b/"
  "/a/b/."     -> "/a/b/"
  "/a/b/.."    -> "/a/"
  "/.."        -> "/"
  "/"          -> "/"
```

## The one thing to know

`canon-path` always returns an **absolute** path, and it silently discards any
`..` that would climb above the start of the string.

```raku name="absolute"
use Path::Canonical;

for 'a/b', './a/b', '../a/b', 'a/../../b', '', '.', '..' -> $p {
    say sprintf('  %-12s -> %s', $p.raku, canon-path($p).raku);
}
say '';
say 'a relative path goes in and an absolute one comes out, rooted at /.';
say 'A programmer reaching for a "canonicalise" helper will feed it a';
say 'relative path and get back something pointing somewhere else';
say 'entirely.';
say '';
say 'and it is not idempotent-looking across shapes — /a/b/.. keeps a';
say 'trailing slash while /a/b does not, so string comparison of two';
say '"canonical" paths can disagree.';
```

```output
  "a/b"        -> "/a/b"
  "./a/b"      -> "/a/b"
  "../a/b"     -> "/a/b"
  "a/../../b"  -> "/b"
  ""           -> "/"
  "."          -> "/"
  ".."         -> "/"

a relative path goes in and an absolute one comes out, rooted at /.
A programmer reaching for a "canonicalise" helper will feed it a
relative path and get back something pointing somewhere else
entirely.

and it is not idempotent-looking across shapes — /a/b/.. keeps a
trailing slash while /a/b does not, so string comparison of two
"canonical" paths can disagree.
```

## It is not `.resolve`

```raku name="symlink"
use Path::Canonical;

my $base = $*TMPDIR.add("canon-{$*PID}");
LEAVE { $base.add('sibling/target.txt').unlink; $base.add('sibling').rmdir;
        $base.add('real/deep').rmdir; $base.add('real').rmdir;
        $base.add('link').unlink; $base.rmdir }
$base.add('real/deep').mkdir;
$base.add('sibling').mkdir;
$base.add('sibling/target.txt').spurt('x');
run 'ln', '-s', $base.add('real/deep').Str, $base.add('link').Str;

my $input = $base.add('link/../sibling/target.txt').Str;
say 'input           : ', $input.subst($base.Str, '<FIX>');
say 'canon-path      : ', canon-path($input).subst($base.Str, '<FIX>');
say '  exists?       : ', canon-path($input).IO.e;
say 'core .resolve   : ', $input.IO.resolve.Str.subst($base.Str, '<FIX>');
say '  exists?       : ', $input.IO.resolve.e;
say '';
say 'the module collapses .. textually, so it names a file that exists —';
say 'and is NOT the file the kernel would open. Core .resolve follows the';
say 'symlink first and gives the other answer. Use .resolve when the';
say 'filesystem is what you mean.';
say '';
say 'and on a path that does not exist, .cleanup and .resolve leave the';
say '.. in place while this module removes it:';
say '  canon-path : ', canon-path('/no/such/dir/../file');
say '  .cleanup   : ', '/no/such/dir/../file'.IO.cleanup;
```

```output
input           : <FIX>/link/../sibling/target.txt
canon-path      : <FIX>/sibling/target.txt
  exists?       : True
core .resolve   : /private<FIX>/real/sibling/target.txt
  exists?       : False

the module collapses .. textually, so it names a file that exists —
and is NOT the file the kernel would open. Core .resolve follows the
symlink first and gives the other answer. Use .resolve when the
filesystem is what you mean.

and on a path that does not exist, .cleanup and .resolve leave the
.. in place while this module removes it:
  canon-path : /no/such/file
  .cleanup   : "/no/such/dir/../file".IO
```

## Where the two engines differ

One argument shape: `canon-path(Str)` — the type object — returns `'/'` under
Raku++ and raises `X::Multi::NoMatch` under Rakudo. `canon-filepath(Str)`
returns `'/'` on both, because of its `$path || ''` guard. Pass a defined
string and the two agree everywhere.

```raku name="filepath"
use Path::Canonical;

say 'the distribution exports a second sub with a Windows branch:';
for '/a/b/../c', 'C:\\tmp\\x', 'a\\b' -> $p {
    say sprintf('  %-14s canon-path=%-14s canon-filepath=%s',
                $p.raku, canon-path($p).raku, canon-filepath($p).raku);
}
say '';
say 'off Windows that branch is unreachable, so canon-filepath is a';
say 'slower alias for canon-path — including for the backslash cases,';
say 'which it makes no attempt to handle.';
say '';
say 'the unit also declares an empty `class Path::Canonical` with no';
say 'members; the two subs are the whole distribution.';
```

```output
the distribution exports a second sub with a Windows branch:
  "/a/b/../c"    canon-path="/a/c"         canon-filepath="/a/c"
  "C:\\tmp\\x"   canon-path="/C:\\tmp\\x"  canon-filepath="/C:\\tmp\\x"
  "a\\b"         canon-path="/a\\b"        canon-filepath="/a\\b"

off Windows that branch is unreachable, so canon-filepath is a
slower alias for canon-path — including for the backslash cases,
which it makes no attempt to handle.

the unit also declares an empty `class Path::Canonical` with no
members; the two subs are the whole distribution.
```
