---
name: paths
version: 10.2
auth: zef:lizmat
kind: Distribution · files
summary: A recursive file finder that returns a lazy Seq of absolute paths, with
  separate matchers for directories and files — and a `:recurse` flag that does
  not mean what its name suggests.
status: full
suite: 3 files, green
tested: 2026-09-16
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/paths
source: https://github.com/lizmat/paths.git
---

## What it is for

`dir` is in the core and recurses into nothing. Writing the recursion yourself
is six lines and they are the same six lines every time, plus the two you
forget: skipping the directories you cannot read, and not following a symlink
into a loop.

`paths` is those lines, as a lazy `Seq` of absolute path strings. Lazy matters:
`paths($root).first(*.ends-with('.lock'))` stops walking when it finds one.

## Walking a tree

```raku name="walk"
use paths;

my $root = $*TMPDIR.add('paths-demo-' ~ $*PID);
for <keep/a.txt keep/inner/b.txt skip/a.txt skip/inner/b.txt root.txt> -> $rel {
    my $f = $root.add($rel);
    $f.parent.mkdir;
    $f.spurt('x');
}
sub rel($p) { $p.substr($root.Str.chars + 1) }
sub show($label, @found) { say sprintf('%-26s %s', $label, @found.map(&rel).sort.join('  ')) }

show 'everything:',       paths($root).list;
show 'only *.txt:',       paths($root, :file(/ '.txt' $ /)).list;
show ':!recurse alone:',  paths($root, :!recurse).list;
say '';
show ':dir(keep) :!recurse', paths($root, :dir(/ keep | inner /), :!recurse).list;
show ':dir(keep) :recurse',  paths($root, :dir(/ keep | inner /), :recurse).list;

run 'rm', '-rf', $root.Str;
```

```output
everything:                keep/a.txt  keep/inner/b.txt  root.txt  skip/a.txt  skip/inner/b.txt
only *.txt:                keep/a.txt  keep/inner/b.txt  root.txt  skip/a.txt  skip/inner/b.txt
:!recurse alone:           keep/a.txt  keep/inner/b.txt  root.txt  skip/a.txt  skip/inner/b.txt

:dir(keep) :!recurse       keep/a.txt  keep/inner/b.txt  root.txt
:dir(keep) :recurse        keep/a.txt  keep/inner/b.txt  root.txt  skip/inner/b.txt
```

`:file` takes anything that smartmatches — a `Regex` as here, a `Str` for an
exact name, a `Callable` for anything else — and so does `:dir`. The filters are
independent: `:file` decides what is *returned*, `:dir` decides what is
*entered*.

## The one thing to know

Look at the third line of output. `:!recurse` returned the whole tree — the same
five files as the default. The flag is not an on/off switch for recursion.

`:recurse` asks: *should the walk descend into directories that do not match
`:dir`?* The module's own source says so in a comment — `# recurse on
non-matching dirs?` — and with no `:dir` matcher every directory matches, so the
flag has nothing to decide and the walk is fully recursive either way.

The last two lines are the flag doing its job. With `:dir(/ keep | inner /)`:

* `:!recurse` visits `keep/` and `keep/inner/` and stops at `skip/`, because
  `skip` does not match and descending into non-matching directories is off.
* `:recurse` descends *through* the non-matching `skip/` and finds
  `skip/inner/b.txt`, because `inner` matches even though its parent does not.

So `:dir` alone prunes, and `:recurse` says whether the pruning is a wall or a
filter. If what you wanted was "this directory only, no subdirectories", that is
`dir($path)` from the core, not this module.

`root.txt` appears in all of them: files directly in the starting directory are
not subject to `:dir` at all.

## Where the two engines differ

Nowhere. Every walk above, including both `:dir`/`:recurse` combinations,
produced identical output on Raku++ and Rakudo, and the three test files pass on
both.

One portability note that is about the shell rather than the engines: the paths
come back absolute and unsorted — the order is the filesystem's. Sort them if
you are going to print them, which is what the example does and what any test
of your own should do.
