---
name: IO::Glob
version: 0.9.0
auth: cpan:HANENKAMP
kind: Distribution · files
summary: Shell wildcards in Raku — `*.txt`, `src/**/*.rakumod`,
  `{one,two}` — as a matcher for strings and paths and as a way to list a
  directory, with the shell's grammar rather than a regex to write.
status: full
suite: 8 files, green
tested: 2026-09-14
license: Artistic-2.0
depends: Test, Test::META
raku-land: https://raku.land/cpan:HANENKAMP/IO::Glob
source: https://github.com/zostay/perl6-IO-Glob
---

## What it is for

`dir` gives you every entry in a directory and a `grep` filters it, which is
fine until the filter is `*.txt` written as a regex — `/ '.txt' $ /` — and
someone asks for `src/**/*.rakumod`. Everyone already knows the shell's
wildcards; this distribution parses them into a matcher. A `glob` object
smartmatches a string, filters a list with `grep`, and walks a directory
with `.dir`, in the shell's own grammar: `*`, `?`, `[a-z]` classes, and the
`{one,two}` alternatives that `bash` calls brace expansion.

## Matching and listing

```raku name="match-and-list"
use IO::Glob;

say 'notes.txt' ~~ glob('*.txt');
say 'notes.TXT' ~~ glob('*.txt');
say <a.raku b.rakumod c.txt>.grep(glob('*.raku*'));
say <one two three>.grep(glob('{one,two}'));
say 'src/lib/Foo.rakumod' ~~ glob('src/**/*.rakumod');

my $dir = $*TMPDIR.add("glob-{$*PID}");
$dir.mkdir;
$dir.add($_).spurt('') for <alpha.txt beta.txt gamma.md>;
$dir.add('sub').mkdir;
$dir.add('sub/delta.txt').spurt('');
say glob('*.txt').dir($dir.Str).map(*.basename).sort;
say glob('*').dir($dir.Str).map(*.basename).sort;
say glob('**/*.txt').dir($dir.Str).map({ .relative($dir) }).sort;
.unlink for $dir.add('sub/delta.txt'), $dir.add('alpha.txt'), $dir.add('beta.txt'), $dir.add('gamma.md');
$dir.add('sub').rmdir;
$dir.rmdir;
```

```output
True
False
(a.raku b.rakumod)
(one two)
True
(alpha.txt beta.txt)
(. .. alpha.txt beta.txt gamma.md sub)
(sub/delta.txt)
```

`glob` returns an object; `~~` matches a string against it, `grep` takes
it as a matcher, and `.dir` lists a directory through it, returning
`IO::Path`s. The grammar defaults to the shell's — `:bsd` and `:simple`
select the two narrower dialects the module also knows.

## The one thing to know

`**` means *one or more directories*, not *zero or more*. The last listing
above finds `sub/delta.txt` and not `alpha.txt`, because `**/*.txt` requires
a directory in front of the file — unlike `bash` with `globstar` on, where
`**/` also matches nothing at all. To get both levels, ask twice
(`glob('*.txt')` and `glob('**/*.txt')`) or match the `.dir` of a plain
recursive walk against `glob('*.txt')` by basename.

Two smaller shell habits carry over exactly. `*` matches `.` and `..`, as
the middle listing shows, so a "delete everything that matches" loop wants
a filter. And matching is case-sensitive — `*.txt` does not find
`notes.TXT` — which is the shell's rule on Linux and a surprise coming from
macOS, where the file system would have found it.
