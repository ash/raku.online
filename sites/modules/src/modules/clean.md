---
name: Clean
version: *
auth: github:azawawi
kind: Distribution · resources
summary: A fifteen-line destructor convention — mark a class with a role,
  implement clean, and call a sub that runs your block and then cleans up.
status: partial
suite: 3 files, green
tested: 2026-09-15
license: MIT
depends: none beyond the core
raku-land: https://raku.land/github:azawawi/Clean
source: git://github.com/azawawi/perl6-clean.git
---

## What it is for

Raku has no destructors. An object holding a file handle, a socket or a lock
has to be told to let go, and the language's answer is a `LEAVE` phaser rather
than anything on the object itself.

This distribution proposes a convention instead: a role that marks a class as
having a cleanup step, and a sub that runs your work and then takes it.

## The convention

```raku name="clean"
use Clean;

class TempResource does Cleanable {
    has Str  $.name;
    has Bool $.open is rw = True;
    method clean() { $!open = False; say "  clean: released $!name" }
}

my $r = TempResource.new(name => 'socket-7');
say 'before : open=', $r.open;
clean $r, -> $o { say "  block sees {$o.name}, open={$o.open}" };
say 'after  : open=', $r.open;
```

```output
before : open=True
  block sees socket-7, open=True
  clean: released socket-7
after  : open=False
```

Fifteen lines of implementation, and the whole body is `&block($o) if
&block.defined; $o.clean if $o.defined`.

## What the role enforces

```raku name="role"
use Clean;

say 'the role stubs a clean method, so a class that does not implement it';
say 'is refused at composition time:';
my $r = try EVAL 'use Clean; class NoImpl does Cleanable { }; NoImpl.new';
say '  ', $! ?? 'refused: ' ~ $!.message.lines[0] !! 'composed';
```

```output
the role stubs a clean method, so a class that does not implement it
is refused at composition time:
  refused: Method 'clean' must be implemented by NoImpl because it is required by roles: Clean::Cleanable.
```

That much works, on both engines, and it is the useful half of the
distribution: `$thing ~~ Cleanable` is a real type test and a class claiming
it really does have a `clean`.

## The one thing to know

`clean` is not exception-safe, so the cleanup it promises does not happen on
the path that most needs it.

```raku name="exception-trap"
use Clean;

class Resource does Cleanable {
    has Str  $.name;
    has Bool $.released is rw = False;
    method clean() { $!released = True }
}

my $a = Resource.new(name => 'A');
try { clean $a, -> $o { die 'boom inside the block' } };
say 'the block died, and A was released : ', $a.released;
say '';
say 'the same shape written with a real LEAVE phaser:';
my $b = Resource.new(name => 'B');
try {
    sub scoped(Resource $o, &blk) { LEAVE $o.clean; blk($o) }
    scoped $b, -> $o { die 'boom inside the block' };
}
say '  B was released : ', $b.released;
```

```output
the block died, and A was released : False

the same shape written with a real LEAVE phaser:
  B was released : True
```

The implementation is `&block($o); $o.clean;` with no `LEAVE`, no `KEEP`, no
`UNDO` and no `try`. A destructor that skips on exception is the opposite of
what a scope guard is for — the exceptional path is the only one where you
cannot clean up by hand afterwards.

Use `LEAVE` directly, as the second half of that example does. The role is
still worth having for the type check.

## Where the two engines differ

On whether the type constraint is enforced at all.

`clean` is declared `clean(Cleanable $o, &block)`. Rakudo refuses a
non-`Cleanable` argument at binding time with a clear message. Raku++ does not
check it: the block **runs** with whatever you passed, and the failure is
deferred to `$o.clean` — or, with an undefined argument, never happens at all,
and `clean` returns having silently done nothing.

So a bug that Rakudo catches at the call site runs half-way through on Raku++
before failing somewhere else.

Three smaller things, the same on both. The parameter is `Cleanable $o`
without `:D`, so a **type object** binds and is silently skipped. The return
value is whatever the trailing `if` statement produced — `True` when the clean
ran and an empty `Slip` when it did not — which is meaningless; do not test
it. And the distribution's metadata carries **no version and no auth**, so
`use Clean:ver<…>` cannot pin anything.
