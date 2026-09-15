---
name: P5opendir
version: 0.0.10
auth: zef:lizmat
kind: Distribution · filesystem
summary: Perl's directory-handle vocabulary — opendir, readdir, telldir,
  seekdir, rewinddir, closedir — over a snapshot of the names taken at open
  time.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5opendir
source: https://github.com/lizmat/P5opendir.git
---

## What it is for

Porting Perl that walks directories means either rewriting every
`opendir`/`readdir` loop as `.dir`, or keeping the loop and supplying the
vocabulary. This distribution supplies the vocabulary — six subs with the
Perl names and the Perl argument shapes, including `telldir` and `seekdir`,
which Raku has no equivalent for at all.

It is the one module in this family that is not NativeCall: the handle is a
Raku class holding an array of names and a cursor.

## Walking a directory

```raku name="walk"
use P5opendir;

my $fixture = $*TMPDIR.add("p5od-{$*PID}");
$fixture.mkdir;
LEAVE { .unlink for $fixture.dir; $fixture.rmdir }
$fixture.add($_).spurt('x') for <alpha beta gamma>;

my $dh;
say 'opendir returned : ', opendir($dh, $fixture.Str);
say 'handle type      : ', $dh.^name;
say 'it stringifies to the path : ', $dh.Str eq $fixture.Str;
say '';
say 'telldir at the start : ', telldir($dh);
say 'first entry  : ', readdir(Scalar, $dh);
say 'second entry : ', readdir(Scalar, $dh);
say 'telldir now  : ', telldir($dh);
rewinddir($dh);
say 'after rewinddir : ', telldir($dh);
say '';
say 'closedir : ', closedir($dh);
```

```output
opendir returned : True
handle type      : DIRHANDLE
it stringifies to the path : True

telldir at the start : 0
first entry  : .
second entry : ..
telldir now  : 2
after rewinddir : 0

closedir : True
```

`.` and `..` are normalised to the front of the list whether or not the
filesystem reported them, so the first two entries are always those. One name
at a time comes from `readdir(Scalar, $dh)` — the same `Scalar` type-object
convention the rest of the `P5*` family uses for Perl's scalar context.

## The list form

```raku name="list"
use P5opendir;

my $fixture = $*TMPDIR.add("p5od2-{$*PID}");
$fixture.mkdir;
LEAVE { .unlink for $fixture.dir; $fixture.rmdir }
$fixture.add($_).spurt('x') for <alpha beta>;

my $dh;
opendir($dh, $fixture.Str);
say 'everything still to come : ', readdir($dh).sort.join(' ');
say 'and again                : ', readdir($dh).elems, ' entries';
```

```output
everything still to come : . .. alpha beta
and again                : 0 entries
```

Which is the first surprise, and the one worth knowing about.

## The one thing to know

`readdir` in list form does not read the handle, it **empties** it —
`rewinddir` cannot get the names back.

```raku name="splice-trap"
use P5opendir;

my $fixture = $*TMPDIR.add("p5od3-{$*PID}");
$fixture.mkdir;
LEAVE { .unlink for $fixture.dir; $fixture.rmdir }
$fixture.add($_).spurt('x') for <alpha beta>;

my $dh;
opendir($dh, $fixture.Str);
say 'elems before reading : ', $dh.elems;
say '';
say 'the Scalar form is non-destructive:';
say '  one   : ', readdir(Scalar, $dh);
rewinddir($dh);
say '  again : ', readdir(Scalar, $dh);
say '  elems : ', $dh.elems;
say '';
say 'the list form splices the names OUT:';
my @all = readdir($dh);
say '  got   : ', @all.sort.join(' ');
say '  elems : ', $dh.elems;
rewinddir($dh);
say '  after rewinddir, readdir gives : ', readdir($dh).elems, ' entries';
say '  and readdir(Scalar, ...) gives : ', readdir(Scalar, $dh).raku;
```

```output
elems before reading : 4

the Scalar form is non-destructive:
  one   : .
  again : .
  elems : 4

the list form splices the names OUT:
  got   : .. alpha beta
  elems : 1
  after rewinddir, readdir gives : 1 entries
  and readdir(Scalar, ...) gives : Nil
```

The list candidate is implemented as `@!items.splice($!index)`, which removes
the entries as it returns them. The one-at-a-time form is the only one
`rewinddir` and `seekdir` actually work with.

A closely related surprise: the handle is a **snapshot** taken at `opendir`
time. Files created afterwards are invisible; files deleted afterwards are
still listed. And `closedir` is a literal `True` that releases nothing — the
handle keeps working after it.

## Where the two engines differ

Only in the wording of the `X::Multi::NoMatch` message you get for misusing a
handle, and in one place where a Rakudo core method is missing from Raku++.

The module has two deliberate "this feature was removed" error paths, and both
format their message with `Str.naive-word-wrapper` — a Rakudo core method that
Raku++ does not have. So `readdir(Mu, $dh)` and the `:void` form die with the
intended message on Rakudo and with `No such method 'naive-word-wrapper'` on
Raku++. Both die; neither tells you the same thing.

One thing that is not an engine difference and will bite a port: `opendir` on
a missing path returns an **undefined value, not `False`** — the `$success =
False` in the source is unreachable, because the `CATCH` unwinds the sub
first. Test the handle, not the return value. `seekdir` clamps silently in
both directions.
