---
name: Sys::Domainname
version: 0.1.0
auth: zef:jmaslak
kind: Distribution · system
summary: Report the machine's DNS domain, by running hostname and removing
  everything up to the first dot.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:jmaslak/Sys::Domainname
source: https://github.com/jmaslak/Raku-Sys-Domainname.git
---

## What it is for

A program that builds a fully-qualified name, a mail identifier or a default
service address wants the machine's DNS domain, and `$*KERNEL.hostname` gives
you the whole thing rather than the domain part.

This distribution is the one sub that separates them.

## Asking for the domain

The answer is specific to the machine, so an example asserts **shape**:

```raku name="domain"
use Sys::Domainname;

my $d = domainname();
say 'returns a Str        : ', $d ~~ Str;
say 'is defined           : ', $d.defined;
say 'has no trailing newline : ', !$d.contains("\n");
```

```output
returns a Str        : True
is defined           : True
has no trailing newline : True
```

That is the entire interface — one exported sub, no arguments.

## How it works

```raku name="mechanism"
use Sys::Domainname;

say 'this is not a syscall. the implementation is four lines:';
say '  run `hostname -f`, chomp it, delete up to and including the first dot.';
say '';
say 'so the answer depends on what `hostname` is on your PATH,';
say 'and on whether the name it prints contains a dot at all.';
say '';
say 'the sub is declared `sub ... is export` at file scope,';
say 'so it is importable but never qualifiable:';
say '  Sys::Domainname::domainname is reachable : ',
    (try &Sys::Domainname::domainname.defined).defined;
```

```output
this is not a syscall. the implementation is four lines:
  run `hostname -f`, chomp it, delete up to and including the first dot.

so the answer depends on what `hostname` is on your PATH,
and on whether the name it prints contains a dot at all.

the sub is declared `sub ... is export` at file scope,
so it is importable but never qualifiable:
  Sys::Domainname::domainname is reachable : True
```

## The one thing to know

It forks a shell, and it never returns an undefined value — so there is no
signal that anything went wrong.

A hostname with **no dot in it** is returned whole, because the stripping is a
plain "delete up to the first dot" with no fallback. So a machine with no
domain reports its own hostname as its domain.

And when `hostname` fails, or is not on the `PATH` at all, the shell writes
`command not found` to **stderr** and the sub returns the **defined empty
string**. The `CATCH { return Str }` in the source is unreachable, because a
failing external command produces empty output rather than throwing.

`.defined` is therefore useless as a success test. `$d.chars` is the only
signal, and even that cannot distinguish "this machine has no domain" from
"`hostname` is missing".

Two consequences worth planning for. Because the answer comes from a subprocess
resolved through `PATH`, it can be **changed by changing `PATH`** — this is
not a trusted source of identity. And every call forks a process, with no
caching, so do not put it in a loop.

## Where the two engines differ

Not in this module, but in something it makes visible. `qx` and `qqx` do
**not** pass the current `%*ENV` to the child under Raku++, while `run` and
`shell` do — so a mutated `PATH` or any other environment change is invisible
to a backtick command on one engine and honoured on the other.

That matters here because the module shells out. It also matters to anything
else that sets an environment variable and then shells out expecting the child
to see it. Use `run` or `shell` with an explicit environment rather than
backticks if the child needs to see your changes.

Everything about this module's own behaviour was identical on both engines.
