---
name: Storable::Lite
version: 0.0.2
auth: zef:tbrowder
kind: Distribution · serialisation
summary: Persist a Raku value to a file and read it back, using Raku source as
  the on-disk format.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:tbrowder/Storable::Lite
source: https://github.com/tbrowder/Storable-Lite.git
---

## What it is for

Saving a Raku data structure between runs usually means choosing a format and
losing something to it: JSON has no `Rat` and no `Set`, YAML has no types at
all, and a binary format needs a schema.

This distribution takes the shortest path. It writes `$value.raku` and reads
it back with `EVAL`, so anything whose `.raku` round-trips survives exactly.

## Saving and loading

```raku name="store"
use Storable::Lite;

my $dir = $*TMPDIR.add("store-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }
my $f = $dir.add('x.raku').absolute;

sub trip($label, $v) {
    to-file($f, $v);
    my $back = from-file($f);
    say sprintf('%-8s same type=%-5s eqv=%s',
        $label, $v.WHAT === $back.WHAT, $v eqv $back);
}

trip 'Int',   42;
trip 'Str',   'hi';
trip 'Rat',   1/3;
trip 'Array', [1, 'two', 3.5];
trip 'Hash',  { a => 1, b => 'x' };
trip 'Bool',  True;
trip 'Set',   set(<a b>);
trip 'Date',  Date.new('2024-03-01');
```

```output
Int      same type=True  eqv=True
Str      same type=True  eqv=True
Rat      same type=True  eqv=True
Array    same type=True  eqv=True
Hash     same type=True  eqv=True
Bool     same type=True  eqv=True
Set      same type=True  eqv=True
Date     same type=True  eqv=True
```

A `Rat` stays a `Rat`, a `Set` stays a `Set` and a `Date` stays a `Date` —
which no text format above manages without a schema.

## What the file holds

```raku name="format"
use Storable::Lite;

my $dir = $*TMPDIR.add("store2-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }
my $f = $dir.add('conf.raku').absolute;

to-file($f, [ 'example.invalid', 8080, 3 ]);
say 'the file is Raku source:';
say '  ', $f.IO.slurp.trim;
say '';
say 'which is why it reads back with its types intact:';
say '  ', from-file($f).map(*.^name).join(' ');
```

```output
the file is Raku source:
  $["example.invalid", 8080, 3]

which is why it reads back with its types intact:
  Str Int Int
```

Which is the appeal and the warning in one line.

## The role

```raku name="role"
use Storable::Lite;

class Config does FileStore {
    has Str $.host is rw;
    has Int $.port is rw;
}

my $dir = $*TMPDIR.add("store3-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }
my $f = $dir.add('c.raku').absolute;

say 'the role adds instance methods : ',
    Config.^can('to-file') && Config.^can('from-file') ?? 'to-file and from-file' !! 'none';
```

```output
the role adds instance methods : to-file and from-file
```

`FileStore` gives a class the same two operations as methods rather than subs.

## The one thing to know

`from-file` is `EVAL`. Reading a data file **executes** it.

The unit opens with `use MONKEY-SEE-NO-EVAL` and `from-file` slurps the file
and evaluates its contents as Raku source. A file that contains
`BEGIN { run 'rm', '-rf', $some-path }; 99` will do exactly that and then
return 99, and nothing in the interface distinguishes it from a file holding
the number 99.

This is fine for a file your own program wrote in a directory your own program
controls. It is not a data format. Do not point `from-file` at anything a user
supplied, anything that arrived over a network, or anything in a
world-writable directory — it is equivalent to `raku that-file`.

If you need to read untrusted structured data, use JSON.

## Where the two engines differ

Nowhere. Every type in this page round-tripped identically on Raku++ and
Rakudo, and the on-disk format is the same text.

Two smaller returns to know about, the same on both. An **empty file** gives
back an undefined value rather than an error, and a **missing file** gives
back `False` — so neither failure throws, and both look like data.
