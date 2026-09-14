---
name: Test::Output
version: 1.001006
auth: zef:raku-community-modules
kind: Distribution · testing
summary: Captures what a block writes to STDOUT and STDERR, either handing you
  the text or asserting on it directly as a test — the missing piece for
  testing code whose real output is printed, not returned.
status: full
suite: 2 files, green
tested: 2026-09-14
license: Artistic-2.0
depends: Test
raku-land: https://raku.land/zef:raku-community-modules/Test::Output
source: https://github.com/raku-community-modules/Test-Output
---

## What it is for

Plenty of code is worth testing precisely because it prints: a usage message, a
progress line, a warning on `$*ERR`, the formatted table a report subcommand
emits. None of it is reachable through a return value, and the usual
alternative — restructuring the code so the string is returned and printed by
someone else — is a real design change made for the test's convenience rather
than the program's.

This module rebinds `$*OUT` and `$*ERR` around a block and collects what lands
there. Ten exported subs, in two groups: three that *return* the captured text,
and six that *assert* on it as `Test` assertions.

## Capture, or assert

The `-from` subs hand the text back, and are plain functions — usable outside a
test file entirely:

```raku name="capture"
use Test::Output;

sub greet($name) { print "hello, $name"; note "greeted $name" }

my $out = stdout-from { greet('world') };
my $err = stderr-from { greet('world') };

say "out: $out.raku()";
say "err: $err.raku()";
```

```output
out: "hello, world"
err: "greeted world\n"
```

`output-from` is the third: it captures both streams into one string, in the
order they were written.

In a test file you rarely want the string itself, only a verdict on it, and the
`-is` and `-like` pairs are `Test` assertions that emit TAP directly — note
that the block is the first argument and the description the last, like `Test`'s
own `lives-ok`:

```raku name="assert"
use Test;
use Test::Output;

sub banner($t) { say '== ' ~ $t ~ ' ==' }

plan 3;
stdout-is   { banner('hi') }, "== hi ==\n", 'banner frames its title';
stdout-like { banner('hi') }, /^ '==' /,    'and starts with the rule';
stderr-is   { note 'warned' }, "warned\n",  'note goes to stderr';
```

```output
1..3
ok 1 - banner frames its title
ok 2 - and starts with the rule
ok 3 - note goes to stderr
```

## The one thing to know

The capture works by swapping the dynamic variables `$*OUT` and `$*ERR` for the
duration of the block, and that is the whole mechanism — which tells you exactly
where it stops. Output written by a **child process** never passes through
them, so `run` and `shell` print straight past the capture to the real terminal
and come back as an empty string. Anything reached through a saved handle
rather than the dynamic — a `my $fh = $*OUT` taken earlier, or a module that
cached it at load time — escapes for the same reason.

`say` and `note` from the code under test are fine, because they look the
dynamic up each time. For a subprocess, capture it where it is created:
`run(…, :out, :err)` and read the pipes yourself.
