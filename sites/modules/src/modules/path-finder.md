---
name: Path::Finder
version: 0.4.7
auth: zef:leont
kind: Distribution · files
summary: A composable file-tree walker — build an immutable rule out of
  predicates, hand it a directory, and get back the paths that match, with
  whole subtrees pruned rather than filtered.
status: full
suite: 14 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:leont/Path::Finder
source: https://github.com/leont/path-iterator
---

## What it is for

"Every `.rakumod` under `lib`, skipping anything inside a `.git`" is one
sentence and about fifteen lines of recursive `dir` with a guard in the
middle. The recursion is not the hard part; the pruning is. A filter that
rejects `.git` entries still descends into them, and on a real project that
is most of the walk.

This distribution separates the two. You build a rule out of predicate
methods, each returning a new rule, and hand the finished rule a starting
directory. Rules that prune stop the walk descending rather than discarding
what it found.

## Rules, and pruning

```raku name="find"
use Path::Finder;

my $root = $*TMPDIR.add("pf-{$*PID}");
$root.mkdir;
$root.add('lib').mkdir;
$root.add('lib/deep').mkdir;
$root.add('.git').mkdir;
$root.add('README.md').spurt("top\n");
$root.add('lib/A.rakumod').spurt("unit class A;\n");
$root.add('lib/deep/B.rakumod').spurt("unit class B;\nneedle\n");
$root.add('.git/config').spurt("[core]\n");

say find($root, :file, :name('*.rakumod'), :relative).map(~*).sort;
say find($root, :file, :lines(/needle/), :relative).map(~*).sort;
say find($root, :directory, :relative).map(~*).sort;
say find($root, :file, :skip-dir('.git'), :relative).map(~*).sort;

my $rule = Path::Finder.file.name('*.md');
say $rule.in($root, :relative).map(~*).sort;
say $rule.^name;

sub nuke($d) { for $d.dir { $_.d ?? nuke($_) !! .unlink }; rmdir $d }
nuke($root);
```

```output
(lib/A.rakumod lib/deep/B.rakumod)
(lib/deep/B.rakumod)
(. .git lib lib/deep)
(README.md lib/A.rakumod lib/deep/B.rakumod)
(README.md)
Path::Finder
```

`find` takes the rules as named options; the builder form takes them as
chained methods and hands back a rule object you can keep and reuse.
`:lines` matches the file's *contents*, which is the predicate that turns a
walk into a search.

Rules are immutable — each method returns a new one — so a base rule can be
narrowed several different ways without the variants interfering.

## The one thing to know

`skip-dir` prunes the starting directory itself; `skip-subdir` does not:

```raku name="skip-dir"
use Path::Finder;

my $root = $*TMPDIR.add("pfs-{$*PID}");
$root.mkdir;
$root.add('node_modules').mkdir;
$root.add('node_modules/pkg').mkdir;
$root.add('node_modules/pkg/y.txt').spurt("y\n");
$root.add('src').mkdir;
$root.add('src/x.txt').spurt("x\n");

say 'from the project root : ',
    find($root, :file, :skip-dir('node_modules'), :relative).elems;
say 'started inside it     : ',
    find($root.add('node_modules'), :file, :skip-dir('node_modules'), :relative).elems;
say 'with skip-subdir      : ',
    find($root.add('node_modules'), :file, :skip-subdir('node_modules'), :relative).elems;

sub nuke($d) { for $d.dir { $_.d ?? nuke($_) !! .unlink }; rmdir $d }
nuke($root);
```

```output
from the project root : 1
started inside it     : 0
with skip-subdir      : 1
```

The rule tests every directory it meets at every depth, including depth
zero — so a tool with `skip-dir('node_modules')` baked in finds *nothing*
when someone runs it from inside `node_modules`. `skip-subdir` guards the
same test with a depth check and behaves as expected. `skip-vcs` is built
on `skip-dir` and inherits the same behaviour, so running your tool from
inside a `.git` directory finds nothing either.

Use `skip-subdir` for anything a user might run from an arbitrary
directory, and keep `skip-dir` for rules applied to a known root.

Two smaller things. `:name` is a **glob**, not a regex, so `:name('.txt')`
matches nothing and `:name('*.txt')` is what you meant — though a `Regex`
passed instead is used as one. And `:ext` compares against the extension
without its dot, so `:ext('txt')` works and `:ext('.txt')` never does.
