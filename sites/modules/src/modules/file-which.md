---
name: File::Which
version: 1.0.4
auth: github:azawawi
kind: Distribution · files
summary: The shell's which, as a function — find the full path of an
  executable on PATH, on every platform, before you try to run it.
status: full
license: MIT
suite: 7 files, green
tested: 2026-08-28
raku-land: https://raku.land/github:azawawi/File::Which
source: https://github.com/azawawi/raku-file-which
---

## What it is for

Your program is about to `run` an external tool — `git`, `ffmpeg`, a
compiler — and there are two ways to learn it is missing: a confusing
failure from `run` at the worst moment, or a clear answer *now*. `which`
is the clear answer: the same lookup the shell's `which` does, as a
function, with the platform differences (Windows' `PATHEXT` extensions,
macOS, plain Unix) chosen for you at load time:

```raku name="which"
use File::Which;

say which('ls');
say which('sh');
say which('definitely-not-a-program-2026').defined;
```

```output
/bin/ls
/bin/sh
False
```

The paths are what this machine answered — yours may differ, which is the
point of asking. The result is a `Str` (or an undefined value for a miss),
so the idiomatic guard is a `with`/`without` or `.defined`, and the result
drops straight into `run`:

```raku fragment
my $git = which('git') // die "this tool needs git on PATH";
run $git, 'status', '--short';
```

## Every hit, and fallback chains

`:all` returns every match in PATH order rather than the first — the tool
for diagnosing "which `python` am I actually getting" — and because a miss
is undefined, a preference list collapses into `first`:

```raku name="all-and-fallbacks"
use File::Which;

my @sh = which('sh', :all);
say so @sh.elems >= 1;
say @sh[0];

my $pager = <a-fancy-pager-you-lack cat>.map({ which($_) }).first(*.defined);
say $pager;
```

```output
True
/bin/sh
/bin/cat
```

The first executable that exists wins; a box with the fancy pager
installed would answer differently, and that is the behaviour being asked
for. There is also `whence`, an alias for `which` imported with
`use File::Which :whence`, for people porting code that used the Perl
module of the same name.

## Where the two engines differ

Nothing on this page. The PATH walk, the executability test and the
platform dispatch answer identically under Raku++ and Rakudo — including
`$*DISTRO`-based selection at `BEGIN` time, which is how the right
per-platform implementation gets picked before the first call.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install File::Which`. This distribution is not in
   the zef index, so the installer resolved it from the REA archive; its
   one dependency is Windows-only (`Win32::Registry`, behind a
   `by-distro.name` gate) and is correctly skipped on this platform.
3. **Test** — the distribution's own suite: 7 files, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

The install step is quietly the interesting one: platform-conditional
dependencies (`depends` entries that name a different module per operating
system) are a META6 corner few distributions use, and this module is where
`rakupp install` proved it handles them.
