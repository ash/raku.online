---
name: if
version: 0.1.5
auth: zef:raku-community-modules
kind: Distribution · system
summary: One pragma — `use if CONDITION, 'Module'` — that loads a distribution
  only when the condition holds, so a platform-only dependency costs nothing on
  the platforms that do not need it.
status: divergent
suite: 1 file, green
tested: 2026-09-16
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/if
source: https://github.com/raku-community-modules/if.git
---

## What it is for

`use` happens at compile time and cannot be put inside an `if`. That leaves a
gap: a module that needs `Win32::Registry` on Windows and nothing on macOS has
no way to say so, and ends up either declaring a dependency that cannot install
off-platform or doing the load by hand through `require`.

This distribution is the missing spelling, in about twenty lines.

## A conditional load

```raku name="ifmod"
# The module named is only looked up when the condition is true. Here it is
# false, and the name is a distribution that does not exist anywhere — which
# is the whole point: a platform-only dependency costs nothing off-platform.
use if $*DISTRO.is-win, 'Win32::Only::Thing';

say 'running on windows : ', $*DISTRO.is-win;
say '';
say 'The statement above named a distribution that is not installed';
say 'and does not exist. With a false condition that is not an error,';
say 'not a warning, and not a lookup — the program simply continues.';
```

```output
running on windows : False

The statement above named a distribution that is not installed
and does not exist. With a false condition that is not an error,
not a warning, and not a lookup — the program simply continues.
```

The name in the false branch is not installed and does not exist. That is the
feature: with a false condition the pragma never resolves the name, so the
distribution need not be present, need not be installable, and need not be real.

## It loads; it does not import

This is the part that catches people, and it is the same on both engines:

```raku fragment
use if True, 'Compress::Zlib';
compress($blob);                      # not imported — this does not resolve
Compress::Zlib::compress($blob);      # nor this
```

`use if` brings the distribution in, but the exported symbols do not reach your
scope. A conditional load is therefore only useful for a module whose effect is
*not* a set of imported names — one that installs a `$*`-variable, registers a
handler, or exists to be reached by fully-qualified class name. For a module
you need to call subs from, `require` with an explicit import list is the tool.

## Where the two engines differ

Two, and the first is one where Raku++ is the one that works.

**Two `use if` statements in the same file do not compile under Rakudo.**

```raku fragment
use if True,  'Digest';
use if False, 'Whatever';
# Rakudo 2026.08:  ===SORRY!===
#                  Cannot iterate object with P6opaque representation (List)
# Raku++:          runs
```

The conditions do not matter — two true, two false, or one of each all fail the
same way, at compile time, before the program starts. Since the entire purpose
of the pragma is platform branching, and a module that branches on one platform
usually branches on two, this is easy to walk into. Raku++ accepts both
statements and runs the program.

**The second is about when the missing import is reported.** Given the
`compress($blob)` above, Rakudo refuses at compile time with "Undeclared
routine", while Raku++ compiles and the call fails at run time. Rakudo's timing
is the better one here — a typo in a name should not wait for the line to be
reached — and a program that relies on Raku++'s laziness will not port.

The distribution's single test file passes on both engines.
