---
name: File::Directory::Bubble
version: 0.1
auth: zef:stuart-little
kind: Distribution · filesystem
summary: The list-building half of a recursive delete — every descendant in an
  order safe to remove in, and how far a deletion would cascade up the parent
  chain.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:stuart-little/File::Directory::Bubble
source: https://github.com/stuart-little/raku-file-directory-bubble.git
---

## What it is for

`rm -r` has one property people rely on and one they wish it had. It removes
the tree; it does not tell you first. And it does not clean up the now-empty
parent directories the removal left behind.

This distribution separates the walking from the removing, so a caller can
print exactly what would go before anything goes — and it walks *upwards* as
well, telling you how far a deletion would cascade once a directory is left
empty.

## Listing a tree

```raku name="down"
use File::Directory::Bubble;

my $root = $*TMPDIR.add("bb-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }

mkdir $root.add('a/b/c');
mkdir $root.add('a/b1/c');
$root.add('a/b1/c/d').spurt('one');
$root.add('foo.txt').spurt('top');

sub rel($p) { $p.Str.subst($root.Str, '<ROOT>') }

say 'bbDown($root), sorted:';
say '  ', $_ for bbDown($root).map(&rel).sort;
say '';
say 'bbDown of an empty directory : ', bbDown($root.add('a/b/c')).map(&rel).List.raku;
say 'listParents of a leaf, first three : ',
    listParents($root.add('a/b1/c/d')).head(3).map(&rel).List.raku;
```

```output
bbDown($root), sorted:
  /private<ROOT>
  /private<ROOT>/a
  /private<ROOT>/a/b
  /private<ROOT>/a/b/c
  /private<ROOT>/a/b1
  /private<ROOT>/a/b1/c
  /private<ROOT>/a/b1/c/d
  /private<ROOT>/foo.txt

bbDown of an empty directory : ("/private<ROOT>/a/b/c",)
listParents of a leaf, first three : ("/private<ROOT>/a/b1/c", "/private<ROOT>/a/b1", "/private<ROOT>/a")
```

`bbDown` includes the directory you pointed at, as the **last** element.

## The removal order

```raku name="order"
use File::Directory::Bubble;

my $root = $*TMPDIR.add("bb2-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }

mkdir $root.add('a/b1/c');
mkdir $root.add('a/b2');
$root.add('a/b1/c/d').spurt('one');
$root.add('a/b2/e').spurt('two');
$root.add('a/f').spurt('three');

sub rel($p) { $p.Str.subst($root.Str, '<ROOT>') }

say 'bbDown(a) in the order it hands them back:';
say '  ', $_ for bbDown($root.add('a')).map(&rel);
say '';
smartRm($_) for bbDown($root.add('a'));
say 'feeding that order straight to smartRm:';
say '  a still exists    : ', $root.add('a').e;
say '  root still exists : ', $root.e;
```

```output
bbDown(a) in the order it hands them back:
  /private<ROOT>/a/b2/e
  /private<ROOT>/a/b2
  /private<ROOT>/a/f
  /private<ROOT>/a/b1/c/d
  /private<ROOT>/a/b1/c
  /private<ROOT>/a/b1
  /private<ROOT>/a

feeding that order straight to smartRm:
  a still exists    : False
  root still exists : True
```

Deepest first, the directory itself last. That is already the safe order — do
**not** `.reverse` it, or every `rmdir` hits a non-empty directory, fails
inside the module's `try`, and says nothing at all.

## Walking upwards

```raku name="up"
use File::Directory::Bubble;

my $root = $*TMPDIR.add("bb3-{$*PID}");
LEAVE { run 'rm', '-rf', $root.Str }

mkdir $root.add('a/b/c');
$root.add('a/keep.txt').spurt('x');

sub rel($p) { $p.Str.subst($root.Str, '<ROOT>') }

say 'noChildrenExcept(a/b/c, [])  : ', noChildrenExcept($root.add('a/b/c'), []);
say 'noChildrenExcept(a, [])      : ', noChildrenExcept($root.add('a'), []);
say '';
say 'bbUpEmpty(a/b/c, []) — how far removing it would cascade:';
say '  ', bbUpEmpty($root.add('a/b/c'), []).map(&rel).List.raku;
say '';
say 'it stops at a, because a still holds keep.txt';
```

```output
noChildrenExcept(a/b/c, [])  : True
noChildrenExcept(a, [])      : False

bbUpEmpty(a/b/c, []) — how far removing it would cascade:
  ("/private<ROOT>/a/b/c", "/private<ROOT>/a/b")

it stops at a, because a still holds keep.txt
```

`bbUpEmpty` is the answer to "if I delete this, what else becomes empty?" — the
thing `rm -r` will not tell you.

## The one thing to know

`bbDown` on a path that does not exist returns neither an empty list nor an
exception, and the natural loop then iterates once over the non-path.

```raku name="missing-trap"
use File::Directory::Bubble;

my $root = $*TMPDIR.add("bb4-{$*PID}");
$root.mkdir;
LEAVE { run 'rm', '-rf', $root.Str }

my $missing = $root.add('no-such-thing');
say 'the path exists            : ', $missing.e;
my $d = bbDown($missing);
say 'bbDown returned a list     : ', $d ~~ Positional;
say 'it is defined              : ', $d.so ~~ Bool;
my @loop;
for $d { @loop.push('one iteration') }
say 'for bbDown($missing) {...} runs : ', @loop.elems, ' time(s)';
say '';
say 'so the guard has to be your own:';
say '  ', $missing.e ?? 'walk it' !! 'skip it';
```

```output
the path exists            : False
bbDown returned a list     : False
it is defined              : True
for bbDown($missing) {...} runs : 1 time(s)

so the guard has to be your own:
  skip it
```

`for bbDown($p) { smartRm($_) }` therefore calls `smartRm` once on something
that is not a path. `smartRm` fails silently in turn — on a non-empty
directory or a missing path it returns a falsy value and throws nothing — so a
deletion loop that ignores return values will report success while leaving the
tree exactly where it was.

Check `.e` before walking, and check what `smartRm` gave you back.

## Where the two engines differ

On what "not a path" is. Raku++ returns `False` from `bbDown` on a missing
path; Rakudo returns an unthrown `Failure` carrying `X::IO::DoesNotExist`.
Rakudo's at least names the problem if you look at it. Both iterate once in a
`for` loop, which is the behaviour that matters.

`smartRm`'s silent-failure return value differs the same way — `False` versus
an empty list — and neither throws.

One naming note, identical on both. You `use File::Directory::Bubble`, and the
package the module actually declares is called **`Bubble`**. Neither name can
qualify the subs: `File::Directory::Bubble::smartRm` and `Bubble::smartRm` are
both undefined. You get seven unprefixed subs into your lexical scope —
`smartRm`, `bbDown` and `listParents` among them, all generic enough to
collide — with no namespace to disambiguate them.
