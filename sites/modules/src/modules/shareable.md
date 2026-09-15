---
name: Shareable
version: 0.0.1
auth: zef:tbrowder
kind: Distribution · serialisation
summary: Inherit from it to get save-yourself-to-a-file — where the store
  file is `.raku` text that gets `EVAL`ed back.
status: divergent
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: Storable::Lite
raku-land: https://raku.land/zef:tbrowder/Shareable
source: https://github.com/tbrowder/Shareable.git
---

## What it is for

Persisting a small object between runs without reaching for JSON or a
database. Inherit from `Shareable`, call `.save`, and the object's `.raku`
goes to a file; `.from-store` reads it back with `EVAL`.

## Saving and loading

```raku name="basics"
use Shareable;

class Note is Shareable { has Str $.title; has Int $.n }

my $f = $*TMPDIR.add("shareable-{$*PID}.store");
LEAVE $f.unlink;

my $a = Note.new(title => 'hello', n => 3);
$a.to-file($f.Str);
say 'file contents : ', $f.slurp.trim;
say '';
my $b = $a.from-file($f.Str);
say 'round-tripped : ', $b.raku;
say '  same class  : ', $b.^name;
say '  equal       : ', $b.title eq $a.title && $b.n == $a.n;
say '  identical   : ', $b === $a;
say '';
say 'from-file returns a NEW object and leaves self untouched — it is not';
say 'an in-place load.';
```

```output
file contents : Note.new(title => "hello", n => 3)

round-tripped : Note.new(title => "hello", n => 3)
  same class  : Note
  equal       : True
  identical   : False

from-file returns a NEW object and leaves self untouched — it is not
an in-place load.
```

## The store file

```raku name="store"
use Shareable;

class Note is Shareable { has Str $.title }

say 'the module keeps ONE module-level store path, shared by every';
say 'instance and subclass, defaulting to $HOME/.Shareable-store-file.';
say '';
say '  .show-store  reads it';
say '  .save        writes self to it';
say '  .store       is the same method under another name';
say '  .from-store  reads it back';
say '';
say 'and .new(:store-file(...)) does NOTHING. The `multi new(:$store-file)`';
say 'in the class body has no `method` keyword, so it is a lexical SUB,';
say 'not a constructor candidate — .new falls through to Mu.new and the';
say 'named argument is dropped:';
say '  ', Note.new(store-file => '/tmp/mine').show-store.IO.basename;
```

```output
the module keeps ONE module-level store path, shared by every
instance and subclass, defaulting to $HOME/.Shareable-store-file.

  .show-store  reads it
  .save        writes self to it
  .store       is the same method under another name
  .from-store  reads it back

and .new(:store-file(...)) does NOTHING. The `multi new(:$store-file)`
in the class body has no `method` keyword, so it is a lexical SUB,
not a constructor candidate — .new falls through to Mu.new and the
named argument is dropped:
  .Shareable-store-file
```

## The one thing to know

`set-store-file($path)` **deletes your existing store file** before adopting
the new one.

```raku name="unlink"
use Shareable;

class Note is Shareable { has Str $.title }

my $dir = $*TMPDIR.add("shareable2-{$*PID}");
LEAVE { $dir.add('a.store').unlink; $dir.add('b.store').unlink; $dir.rmdir }
$dir.mkdir;
my $a = $dir.add('a.store');
my $b = $dir.add('b.store');

my $n = Note.new(title => 'kept');
$n.to-file($a.Str);
say 'file A written : ', $a.e;
$n.set-store-file($b.Str);
say 'after set-store-file(B):';
say '  store is now : ', $n.show-store.IO.basename;
say '  file A       : ', $a.e ?? 'still there' !! 'GONE';
say '';
say 'the source is  method set-store-file($path) { unlink $storefile;';
say '$storefile = $path }. Nothing in the name suggests a deletion.';
say '';
say 'and the FIRST call in a fresh program unlinks whatever is at';
say '$HOME/.Shareable-store-file, because that is the default. "Point this';
say 'object at my own file" is spelled "delete the shared default store,';
say 'then point at my own file".';
```

```output
file A written : True
after set-store-file(B):
  store is now : b.store
  file A       : still there

the source is  method set-store-file($path) { unlink $storefile;
$storefile = $path }. Nothing in the name suggests a deletion.

and the FIRST call in a fresh program unlinks whatever is at
$HOME/.Shareable-store-file, because that is the default. "Point this
object at my own file" is spelled "delete the shared default store,
then point at my own file".
```

## A store file is executable code

```raku name="eval"
use Shareable;

class Note is Shareable { has Str $.title }

my $f = $*TMPDIR.add("shareable3-{$*PID}.store");
LEAVE $f.unlink;
$f.spurt('do { say "  >>> code in the store file just ran <<<"; 42 }');

say 'loading a store file that contains an expression:';
my $r = Note.from-file($f.Str);
say '  result = ', $r.raku;
say '';
say 'Storable::Lite deserialises with EVAL under MONKEY-SEE-NO-EVAL.';
say 'Never point from-file or from-store at a file you did not write.';
say '';
say 'a missing file returns Bool::False after a warning — not Nil, not a';
say 'Failure — so `my $obj = $s.from-store;` silently yields False and';
say 'blows up somewhere else later:';
say '  from-file(missing) : ', Note.from-file('/no/such/store').raku;
```

```output
loading a store file that contains an expression:
  >>> code in the store file just ran <<<
  result = 42

Storable::Lite deserialises with EVAL under MONKEY-SEE-NO-EVAL.
Never point from-file or from-store at a file you did not write.

a missing file returns Bool::False after a warning — not Nil, not a
Failure — so `my $obj = $s.from-store;` silently yields False and
blows up somewhere else later:
  from-file(missing) : Bool::False
```

## Where the two engines differ

Closure attributes come back as empty stubs on both — `.raku` renders a `Sub`
as `sub { ... }`, which `EVAL`s into a live `Sub` whose body is the yada stub.
Calling it then diverges: Raku++ throws `X::StubCode`, Rakudo returns a
`Failure` that is easy to swallow. Keep code out of anything you store.

```raku name="leak"
use Shareable;

say 'the other divergence is scoping: `use Shareable` re-exports its';
say 'dependency`s exports under Raku++ and not under Rakudo.';
say '';
say '  after `use Shareable` alone:';
say '    FileStore, to-file and from-file as SUBS are visible on Raku++';
say '    and "Undeclared name" on Rakudo';
say '';
say 'so code written against Raku++ that calls to-file($path, $obj) as a';
say 'sub does not compile on Rakudo. Use the METHODS the class gives you,';
say 'which are the same on both:';
class Note is Shareable { has Str $.title }
my $f = $*TMPDIR.add("shareable4-{$*PID}.store");
LEAVE $f.unlink;
my $n = Note.new(title => 'portable');
$n.to-file($f.Str);
say '  .to-file / .from-file : ', Note.from-file($f.Str).title;
```

```output
the other divergence is scoping: `use Shareable` re-exports its
dependency`s exports under Raku++ and not under Rakudo.

  after `use Shareable` alone:
    FileStore, to-file and from-file as SUBS are visible on Raku++
    and "Undeclared name" on Rakudo

so code written against Raku++ that calls to-file($path, $obj) as a
sub does not compile on Rakudo. Use the METHODS the class gives you,
which are the same on both:
  .to-file / .from-file : portable
```

One last shape: `Shareable` itself declares no attributes, so
`Shareable.new.raku` is just `Shareable.new`. All the state is yours.
