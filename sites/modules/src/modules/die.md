---
name: Die
version: 1.1
auth: zef:raku-community-modules
kind: Distribution · error handling
summary: Restore Perl's convention that a die message ending in a newline is a
  finished message for the user — printed to stderr, followed by exit 1.
status: full
suite: 3 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Die
source: https://github.com/raku-community-modules/Die.git
---

## What it is for

Perl has a convention forty years old: `die "message\n"` with a trailing
newline means "this is a finished message for the user", and `die "message"`
without one means "this is a programming error, add the file and line". Every
Perl command-line tool relies on it.

Raku dropped it. This distribution puts it back, in six lines of code.

## The convention

```raku name="die"
use Die;

# a message with no trailing newline is still an ordinary exception
my $r = try { die 'plain' };
say 'die("plain") -> caught ', $!.^name, ': ', $!.message;
say '';
say 'a message WITH a trailing newline does not come back here at all —';
say 'it is printed to stderr and the process exits 1.';
```

```output
die("plain") -> caught X::AdHoc: plain

a message WITH a trailing newline does not come back here at all —
it is printed to stderr and the process exits 1.
```

One `multi` is added: `die(Cool:D $msg where *.ends-with("\n"))`. Everything
else — messages without a newline, exception objects, `die` with no arguments
— falls through to the core candidates and throws as usual.

## What still throws

```raku name="falls-through"
use Die;

for 'no newline', 42, 42.5 -> $arg {
    my $r = try { die $arg };
    say sprintf('%-14s -> threw %s', $arg.gist, $!.^name);
}
my $e = try { die X::AdHoc.new(payload => 'an object') };
say sprintf('%-14s -> threw %s', 'an exception', $!.^name);
```

```output
no newline     -> threw X::AdHoc
42             -> threw X::AdHoc
42.5           -> threw X::AdHoc
an exception   -> threw X::AdHoc
```

Only a `Cool` ending in a newline is intercepted. A number, a `Rat` and an
exception object all reach the core.

## The one thing to know

With this module loaded, `die "…\n"` is no longer an exception. `try` and
`CATCH` cannot stop it, and your program ends on the spot.

The candidate does not throw — it calls `note` and `exit 1`. So a `die` placed
inside a `try` block that also carries a `CATCH { default { … } }` produces no
`CATCH`, no code after the `try`, and exit status 1. `END` phasers still run,
because `exit` is an orderly shutdown; `CATCH`, `KEEP` and `UNDO` on the
aborted frame, and everything after the call, do not.

Nothing at the call site signals this. The same `die` keyword, one trailing
whitespace character apart, is catchable or an unstoppable process exit. And a
trailing `\n` is invisible in source and easy to acquire by accident — from a
heredoc, from interpolating a line read off a file, from concatenation.

The reach is wider than your own file, too: the candidate is installed into
the **importing scope**, so a library that loads `Die` changes the meaning of
`die` for its caller's code. Any code with a cleanup `CATCH`, a retry loop, or
a test harness expecting a throw silently stops working.

Load it in a program, never in a library.

## Where the two engines differ

Only in introspection. `&die.candidates` lists just the imported candidate on
Raku++ and the full merged set of seven on Rakudo. Dispatch itself is correct
on both — the same arguments reach the same candidate — so this affects a
`.candidates` listing and nothing else.

Two more things, the same on both. The exit status is hard-coded to **1**;
there is no way to choose another. And the message is chomped by exactly one
trailing newline and written with `note`, so it goes to stderr — which is
where a finished user message belongs, and which means it will not appear in
anything capturing stdout.

The distribution's `provides` maps a unit named `Die`, but the file declares
no package, so there is no `Die::` namespace to qualify anything with.
