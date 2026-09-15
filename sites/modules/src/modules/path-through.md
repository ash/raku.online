---
name: Path::Through
version: 0.0.1
auth: cpan:hythm
kind: Distribution · paths
summary: Four multis that treat an `IO::Path` as a list of `/`-separated
  parts — where `shift` on an absolute path removes the leading slash.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/cpan:hythm/Path::Through
source: https://github.com/hythm7/path-through
---

## What it is for

`IO::Path` has `.add` and `.parent`, and nothing that takes several components
off one end. This distribution adds four verbs with array-like names —
`append`, `prepend`, `pop`, `shift` — that walk a path as if it were the list
of its parts.

## The four verbs

```raku name="basics"
use Path::Through;

my $p = 'a/b/c/d'.IO;
say 'start          : ', $p.Str;
say 'append "e/f"   : ', append($p, 'e/f').Str;
say 'prepend "root" : ', prepend($p, 'root').Str;
say 'pop            : ', pop($p).Str;
say 'pop :2parts    : ', pop($p, parts => 2).Str;
say 'shift          : ', shift($p).Str;
say 'shift :2parts  : ', shift($p, parts => 2).Str;
say '';
say 'they return new IO::Paths; the original is untouched : ', $p.Str;
```

```output
start          : a/b/c/d
append "e/f"   : a/b/c/d/e/f
prepend "root" : root/a/b/c/d
pop            : a/b/c
pop :2parts    : a/b
shift          : b/c/d
shift :2parts  : c/d

they return new IO::Paths; the original is untouched : a/b/c/d
```

## The one thing to know

`shift` on an **absolute** path removes the leading slash, not a component.

```raku name="leading-slash"
use Path::Through;

my $abs = '/a/b/c/d'.IO;
say 'start        : ', $abs.Str;
my $one = shift($abs);
say 'shift x1     : ', $one.Str, '   <- same components, now RELATIVE';
say 'shift x2     : ', shift($one).Str;
say 'shift :3parts: ', shift($abs, parts => 3).Str;
say '';
say '"/a/b/c/d".split("/") is ("", "a", "b", "c", "d"), so the first shift';
say 'consumes the empty leading element. :2parts on an absolute path drops';
say 'ONE component, :3parts drops two, and the absoluteness evaporates on';
say 'the first call.';
say '';
say 'if you mean components, check first:';
sub drop-front(IO::Path $p, Int $n) {
    my $abs = $p.is-absolute;
    my $r = shift($p, parts => $n + ($abs ?? 1 !! 0));
    $abs ?? ('/' ~ $r.Str).IO !! $r
}
say '  drop-front("/a/b/c/d", 2) = ', drop-front('/a/b/c/d'.IO, 2).Str;
```

```output
start        : /a/b/c/d
shift x1     : a/b/c/d   <- same components, now RELATIVE
shift x2     : b/c/d
shift :3parts: c/d

"/a/b/c/d".split("/") is ("", "a", "b", "c", "d"), so the first shift
consumes the empty leading element. :2parts on an absolute path drops
ONE component, :3parts drops two, and the absoluteness evaporates on
the first call.

if you mean components, check first:
  drop-front("/a/b/c/d", 2) = /c/d
```

## Over-popping

```raku name="empty"
use Path::Through;

say 'popping a bare filename, or more parts than there are, produces the';
say 'EMPTY path — which is a very different thing from an error:';
my $r = try pop('file'.IO);
say '  pop("file".IO) -> engine-dependent: an empty path, or a refusal';
say '';
say 'Raku++ hands you "".IO, which stringifies to "" and will resolve';
say 'against the current directory; Rakudo refuses to build such a path';
say 'at all. Guard the part count yourself and neither can reach you:';
sub safe-pop(IO::Path $p, Int $n = 1) {
    my @parts = $p.Str.split('/').grep(*.chars);
    die "cannot drop $n of {+@parts} parts" if $n >= @parts;
    pop($p, parts => $n)
}
for 1, 3 -> $n {
    my $x = try safe-pop('a/b/c'.IO, $n);
    say sprintf('  safe-pop(a/b/c, %d) -> %s', $n, $! ?? $!.message !! $x.Str);
}
```

```output
popping a bare filename, or more parts than there are, produces the
EMPTY path — which is a very different thing from an error:
  pop("file".IO) -> engine-dependent: an empty path, or a refusal

Raku++ hands you "".IO, which stringifies to "" and will resolve
against the current directory; Rakudo refuses to build such a path
at all. Guard the part count yourself and neither can reach you:
  safe-pop(a/b/c, 1) -> a/b
  safe-pop(a/b/c, 3) -> cannot drop 3 of 3 parts
```

## Where the two engines differ

Two core behaviours this module sits directly on top of. `''.IO` is a valid
empty path under Raku++ and raises `Must specify a non-empty string as a path`
under Rakudo; and `'a'.IO.add('/b')` yields `a//b` under Raku++ and `a/b`
under Rakudo. So over-popping is a silent CWD-relative path on one engine and
a loud refusal on the other, and `prepend` produces different path *strings*.

```raku name="prepend"
use Path::Through;

say 'prepend is $prepend.IO.add($path):';
say '  prepend("/b".IO, "a")  -> engine-dependent separator';
say '  prepend("b".IO,  "a")  -> ', prepend('b'.IO, 'a').Str, '   <- agrees';
say '';
say 'so prepend a RELATIVE path, or normalise afterwards:';
say '  .cleanup : ', prepend('/b'.IO, 'a').cleanup.Str;
say '';
say 'one more, introspection only: after importing this module,';
say '&pop.candidates lists the core candidates merged in under Rakudo and';
say 'only the module`s own under Raku++. Dispatch is correct on both —';
say 'core pop on an Array still works — but anything that reasons over';
say '.candidates will get the wrong answer on Raku++.';
my @a = 1, 2, 3;
say '  core pop still works : ', pop(@a), ' leaving ', @a.raku;
```

```output
prepend is $prepend.IO.add($path):
  prepend("/b".IO, "a")  -> engine-dependent separator
  prepend("b".IO,  "a")  -> a/b   <- agrees

so prepend a RELATIVE path, or normalise afterwards:
  .cleanup : a/b

one more, introspection only: after importing this module,
&pop.candidates lists the core candidates merged in under Rakudo and
only the module`s own under Raku++. Dispatch is correct on both —
core pop on an Array still works — but anything that reasons over
.candidates will get the wrong answer on Raku++.
  core pop still works : 3 leaving [1, 2]
```

The module hard-codes `constant DIRSEP = '/'`, matching its own Linux-only
scoping; nothing enforces that, so on Windows the four verbs would be
meaningless rather than wrong.
