---
name: Result
version: 0.2.5
auth: samgwise
kind: Distribution · error handling
summary: A Rust-style Result wrapper — a computation yields an Ok carrying a
  value or an Err carrying a message, and you chain onto it rather than
  throwing.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/samgwise/Result
source: git://github.com/samgwise/p6-result.git
---

## What it is for

Exceptions unwind. That is usually what you want and occasionally exactly what
you do not: in a pipeline of small steps, where a failure at step three should
produce a value describing the failure rather than tearing the pipeline down,
the unwinding is the problem.

Rust's `Result` is the alternative — every step returns either a success or a
failure, and you compose them. This distribution is that pattern for Raku.

## Constructing and inspecting

```raku name="result"
use Result;

my $ok  = Ok(42);
my $err = Err('boom');

for 'Ok(42)', $ok, "Err('boom')", $err -> $label, $r {
    say $label;
    say '  type    : ', $r.^name;
    say '  is-ok   : ', $r.is-ok;
    say '  is-err  : ', $r.is-err;
    say '  Bool    : ', ?$r;
}
say '';
say 'Ok carries a value  : ', $ok.value;
say 'Err carries a Str   : ', $err.error;
```

```output
Ok(42)
  type    : Result::Ok
  is-ok   : True
  is-err  : False
  Bool    : True
Err('boom')
  type    : Result::Err
  is-ok   : False
  is-err  : True
  Bool    : False

Ok carries a value  : 42
Err carries a Str   : boom
```

`Bool` follows `is-ok`, so a `Result` drops straight into an `if`.

## Chaining

```raku name="chain"
use Result;

my $r = Ok(42).map-ok(-> $res { Ok($res.value + 1) })
              .map-ok(-> $res { Ok($res.value * 2) });
say 'two steps on an Ok   : ', $r.value;
say '';
say 'an Err passes through map-ok untouched:';
say '  ', Err('e').map-ok(-> $res { Ok(1) }).error;
say 'and an Ok passes through map-err:';
say '  ', Ok(9).map-err(-> $res { Err('z') }).value;
say '';
say 'map-err on an Err:';
say '  ', Err('boom').map-err(-> $res { Err($res.error ~ '!') }).error;
```

```output
two steps on an Ok   : 86

an Err passes through map-ok untouched:
  e
and an Ok passes through map-err:
  9

map-err on an Err:
  boom!
```

Which is the shape to get right, and the next section is why.

## Turning a throw into a Result

```raku name="capture"
use Result;

my $good = result({ 10 / 2 });
say 'result({ 10 / 2 })   : is-ok=', $good.is-ok, ' value=', $good.value;
say '';
my $bad = result({ die 'kaboom' });
say 'result({ die ... })  : is-err=', $bad.is-err;
say '  the error starts with the message : ', $bad.error.starts-with('kaboom');
say '  but it carries a backtrace too    : ', $bad.error.lines.elems > 1;
```

```output
result({ 10 / 2 })   : is-ok=True value=5

result({ die ... })  : is-err=True
  the error starts with the message : True
  but it carries a backtrace too    : True
```

`result` runs a block and captures a throw. What it stores in `.error` is the
**entire stringified exception including its backtrace and absolute file
paths** — a multi-line blob rather than a message, and one that differs
between engines, so it cannot be asserted in a test. Take `.error.lines[0]` if
you want the message.

## The one thing to know

`map-ok` is a bind, not a map. The block receives the **`Result` wrapper**,
not the value, and must return another `Result`.

```raku name="bind-trap"
use Result;

say 'what the block actually receives:';
Ok(42).map-ok(-> $x { say '  a ', $x.^name, ' carrying ', $x.value; Ok($x) });
say '';
say 'the natural reading fails:';
my $r = try Ok(42).map-ok(-> $x { $x.value + 1 });
say '  ', $! ?? 'threw ' ~ $!.^name !! 'worked';
say '';
say 'the working form unwraps and rewraps:';
say '  ', Ok(42).map-ok(-> $res { Ok($res.value + 1) }).value;
```

```output
what the block actually receives:
  a Result::Ok carrying 42

the natural reading fails:
  threw X::TypeCheck::Return

the working form unwraps and rewraps:
  43
```

The source is `method map-ok(&with-ok --> Result::Any) { return self if
$!is-err; with-ok(self) }` — `self`, not the contained value. So the obvious
`.map-ok(-> $x { $x + 1 })`, which is what the name promises, fails the return
type check.

Read `map-ok` as `and-then`.

## Where the two engines differ

Only in the captured backtrace, which is longer on Raku++ because it names
more intermediate frames. Every method, every pass-through and every type in
this page behaved identically.

Two naming traps, the same on both. **`err-to-undef` on an `Ok` returns
`self`** — the whole wrapper, not the value — which the name strongly suggests
otherwise. And **`Err.ok($msg)` throws**, making `.ok` the one method in the
interface that reintroduces the exceptions the module exists to avoid;
`Ok(7).ok('nope')` returns `7`, so the two branches behave completely
differently.
