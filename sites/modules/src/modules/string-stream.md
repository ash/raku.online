---
name: String::Stream
version: 0.8
auth: github:jaffa4
kind: Distribution · IO
summary: A one-class in-memory sink you print into and read back — and,
  without inheriting anything, a drop-in `$*OUT`.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/github:jaffa4/String::Stream
source: git://github.com/jaffa4/string-stream.git
---

## What it is for

Somewhere between `$text ~= …` and opening a real file sits the thing that
looks like a handle and keeps its bytes in memory. This distribution is 35
lines of exactly that: a class with `print`, `say` and `get`, over one `Str`
buffer.

## Using it

```raku name="basics"
use String::Stream;

my $s = String::Stream.new('');
$s.print('a', 'b');
$s.print('c');
$s.say(42);
$s.print('e');

say 'buffer     : ', $s.get.raku;
say 'read twice : ', $s.get.raku;
say '';
say '.print joins its arguments with NO separator; .say appends "\n".';
say '.get does not consume — read it twice and you get the history twice.';
say '';
my $seeded = String::Stream.new('seed:');
$seeded.print('x');
say 'new(Str)   : ', $seeded.get.raku;
```

```output
buffer     : "abc42\ne"
read twice : "abc42\ne"

.print joins its arguments with NO separator; .say appends "\n".
.get does not consume — read it twice and you get the history twice.

new(Str)   : "seed:x"
```

A fresh stream's buffer is `Any`, not `''` — there is no attribute default,
so `.get.chars` on an untouched stream blows up. Seed it with `.new('')`.

```raku name="fresh"
use String::Stream;

my $fresh = String::Stream.new;
say 'a fresh .get : ', $fresh.get.raku, '   (an undefined Str, not "")';
say '';
say '.buffer is a read-only public accessor:';
say '  reading it : ', String::Stream.new('x').buffer.raku;
my $ok = try { $fresh.buffer = 'zap'; True };
say '  writing it : ', $ok ?? 'succeeded' !! 'refused';
say '';
say '.flush exists and its body is EMPTY. It does not clear, drain or';
say 'commit anything — the name implies otherwise:';
my $f = String::Stream.new('');
$f.print('still here');
$f.flush;
say '  after .flush : ', $f.get.raku;
```

```output
a fresh .get : Any   (an undefined Str, not "")

.buffer is a read-only public accessor:
  reading it : "x"
  writing it : refused

.flush exists and its body is EMPTY. It does not clear, drain or
commit anything — the name implies otherwise:
  after .flush : "still here"
```

## The one thing to know

It is not an `IO::Handle` and inherits nothing, yet it works as a drop-in
`$*OUT` — so it is a two-line output capture.

```raku name="capture"
use String::Stream;

my $cap = String::Stream.new('');
{
    my $*OUT = $cap;
    say 'captured line';
    print 'captured print';
}
say 'nothing in the class advertises this.';
say '';
say 'what the capture holds:';
say '  ', $cap.get.raku;
say '';
say 'core say/print only need .print and .say on the handle, and this';
say 'class happens to have both. No role, no inheritance, no IO::Handle.';
```

```output
nothing in the class advertises this.

what the capture holds:
  "captured line\ncaptured print"

core say/print only need .print and .say on the handle, and this
class happens to have both. No role, no inheritance, no IO::Handle.
```

That is also the whole risk: anything in the captured block that reaches for
a real handle method — `.flush` with meaning, `.encoding`, `.t`, `.close` —
finds either nothing or the no-op above.

## Where the two engines differ

Constructor arguments the class does not declare. Raku++ silently builds an
object with an empty buffer; Rakudo raises `X::Constructor::Positional`.

```raku name="constructor"
use String::Stream;

say 'the two documented forms:';
say '  .new()      -> buffer ', String::Stream.new.get.raku;
say '  .new("seed") -> buffer ', String::Stream.new('seed').get.raku;
say '';
say 'anything else is where the engines part:';
say '  .new(42)        builds with an EMPTY buffer on Raku++,';
say '                  X::Constructor::Positional on Rakudo';
say '  .new("a", "b")  the same';
say '';
say 'so a typo`d constructor argument is lost without a sound on one';
say 'engine and caught on the other. Pass one Str, or none.';
say '';
say 'the safe idiom:';
sub sink(Str $seed = '') { String::Stream.new($seed) }
my $s = sink();
$s.say('line one');
$s.say('line two');
say '  ', $s.get.raku;
```

```output
the two documented forms:
  .new()      -> buffer Any
  .new("seed") -> buffer "seed"

anything else is where the engines part:
  .new(42)        builds with an EMPTY buffer on Raku++,
                  X::Constructor::Positional on Rakudo
  .new("a", "b")  the same

so a typo`d constructor argument is lost without a sound on one
engine and caught on the other. Pass one Str, or none.

the safe idiom:
  "line one\nline two\n"
```

Reduced with no module involved: a class that declares its own
`multi method new` accepts stray positionals under Raku++ and refuses them
under Rakudo — plain multi dispatch is fine on both, it is `new` specifically.

The other thing to plan around, identical on both engines: there is no reset.
`.get` does not consume and `.flush` does nothing, so the only way to start
over is a new object.
