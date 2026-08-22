---
name: File::Temp
version: 0.0.12
auth: zef:raku-community-modules
kind: Distribution · files
summary: A temporary file or directory with a name nobody can guess, created
  safely, and removed for you when the program ends.
status: full
license: Artistic-2.0
depends: File::Directory::Tree
suite: 3 files, green
tested: 2026-08-22
raku-land: https://raku.land/zef:raku-community-modules/File::Temp
source: https://github.com/raku-community-modules/File-Temp
---

## What it is for

You need somewhere to put bytes for the length of one program — a download
before you validate it, a file to hand to an external command, a directory to
unpack an archive into. Writing `/tmp/mydata` yourself has two problems: two
copies of your program collide, and anyone on the machine can guess the name
and get there first. `tempfile` gives you a fresh path, already open, and takes
it away afterwards:

```raku name="tour"
use File::Temp;

my ($path, $fh) = tempfile;
$fh.spurt("two\nlines\n", :close);
say $path.IO.e;
say $path.IO.slurp.lines.elems;
say $path.IO.basename.chars > 0;
```

```output
True
2
True
```

It returns **two** things: the path as a `Str`, and an open `IO::Handle` for
it. The handle matters — the file is created and opened in one step, which is
what closes the window where somebody else could put their own file at that
path first.

## Naming it something recognisable

A run of five or more `*` characters in a template is replaced with random
characters. Or skip the template and use `:prefix` and `:suffix`, which is
usually clearer — a suffix is how you get an extension, and an extension is how
the next program knows what it is looking at:

```raku name="named"
use File::Temp;

my ($path, $fh) = tempfile(:prefix<report->, :suffix<.txt>);
$fh.spurt("id,name\n1,raku\n", :close);
say $path.IO.basename.starts-with('report-');
say $path.IO.extension;
say $path.IO.slurp.lines.elems;
```

```output
True
txt
2
```

`:tempdir` puts the file somewhere other than the system temporary directory —
useful when the file has to end up on the same filesystem as its final
destination, so that moving it into place is an atomic rename rather than a
copy.

## Directories

`tempdir` is the same idea one level up, and it returns just the path:

```raku name="tempdir"
use File::Temp;

my $dir = tempdir;
say $dir.IO.d;
$dir.IO.add('a.txt').spurt('x');
say $dir.IO.dir.elems;
```

```output
True
1
```

The whole tree goes away at exit — that is what the `File::Directory::Tree`
dependency is for. You can put as much as you like inside it and never write a
cleanup path.

## Who removes what, and when

Both functions remove what they made when the **program** ends, not when the
variable goes out of scope. That is the behaviour you want almost always, and
the one that surprises people once:

```raku name="cleanup"
use File::Temp;

my $kept = do {
    my ($p, $fh) = tempfile;
    $fh.close;
    $p;
};
say $kept.IO.e;

my ($keep, $fh2) = tempfile(:!unlink);
$fh2.close;
say $keep.IO.e;
$keep.IO.unlink;
say $keep.IO.e;
```

```output
True
True
False
```

The first file outlives the block it was made in. The second was made with
`:!unlink`, so it is yours to keep — and yours to remove, as the last two lines
do. Reach for `:!unlink` when the file is the *output* of the program rather
than scratch space.

## Where the two engines differ

Nothing on this page — but one thing next to it, worth knowing if you compare
paths as strings.

**`$*TMPDIR.Str` keeps macOS's trailing slash under Rakudo and does not under
Raku++.** Rakudo hands back `/var/folders/…/T/`, Raku++ `/var/folders/…/T`, so
a test like `$path.IO.parent.Str eq $*TMPDIR.Str` passes on one engine and
fails on the other. Compare paths as paths — `$path.IO.parent eq $*TMPDIR.IO`,
or `.resolve` both — and the difference stops mattering.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install File::Temp`, which pulls
   `File::Directory::Tree` with it.
3. **Test** — the distribution's own suite: 3 files, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

Two things had to be fixed to put this page here, and neither was in the
module.

**The installer could not read its dependency.** `File::Temp` 0.0.12 writes its
`depends` as the phase hash the META6 spec allows —
`{"runtime": {"requires": ["File::Directory::Tree:ver<0.2+>"]}}` — rather than
as a list of strings, and `rakupp install` understood only the list. It skipped
the dependency with a note and then the suite could not load it. Two hundred
and twenty-three distributions in the zef index write `depends` that way, so
this was not one module's quirk; it was a hole under a fifth of the ecosystem.

**`$fh.spurt($content, :close)` wrote nothing.** An open handle in Raku++
buffers its writes and flushes them on `.close`; `.spurt` appended to that
buffer and then ignored `:close`, so a program that spurted and immediately
read the path back got an empty file. The module's own suite is written exactly
that way. It is fixed, and pinned by
[t/regression/handle-spurt-close.raku](https://github.com/ash/rakupp/blob/main/t/regression/handle-spurt-close.raku),
which passes under both engines so either can serve as the oracle.
