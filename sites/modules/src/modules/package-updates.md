---
name: Package::Updates
version: 1.0.0
auth: none stated
kind: Distribution · system
summary: Ask the host's system package manager which installed packages have
  newer versions available, as a hash of name to current and new.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/?/Package::Updates
source: git@github.com:ramiroencinas/perl6-Package-Updates.git
---

## What it is for

A monitoring script, a dashboard or a compliance check wants to know whether
the machine it is on has pending package updates. Each package manager answers
that differently — `apt-get -s upgrade`, `pacman -Qu`, `yum check-update` —
and parsing three formats is three jobs.

This distribution picks the right one by probing for a marker directory and
returns a single shape.

## Asking

```raku name="ask"
use Package::Updates;

my $t0 = now;
my %updates = get-updates();
my $elapsed = now - $t0;

say 'returns a : ', %updates.^name;
say 'entries   : ', %updates.elems;
say 'Bool      : ', ?%updates;
say 'and it answered in under a second : ', $elapsed < 1;
```

```output
returns a : Hash
entries   : 0
Bool      : False
and it answered in under a second : True
```

One exported sub, no arguments. Each value in a populated result is a hash of
`current` and `new`.

## How it decides

```raku name="probe"
use Package::Updates;

say 'the module probes for a marker directory:';
for </etc/apt /etc/pacman.d /etc/yum> -> $p {
    say sprintf('  %-16s exists : %s', $p, $p.IO.e);
}
say '  win32 kernel     : ', $*KERNEL.name eq 'win32';
say '';
say 'if none of the four matches, it returns an empty hash.';
```

```output
the module probes for a marker directory:
  /etc/apt         exists : False
  /etc/pacman.d    exists : False
  /etc/yum         exists : False
  win32 kernel     : False

if none of the four matches, it returns an empty hash.
```

Which is the thing to know.

## The one thing to know

"No updates" and "I do not support this operating system" are the **same
return value**.

There is no exception, no `Failure`, no flag and no way for a caller to tell
the two apart. On a machine whose package manager is not one of the four, the
result is `{}` — exactly what a fully up-to-date Debian box returns.

The set of hosts that silently answer `{}` is large: macOS, every BSD, Alpine
and anything else using `apk`, Void, Gentoo, NixOS, and any Debian derivative
where `/etc/apt` has been relocated.

A monitoring check written against this reports "all clear" on every one of
them. Probe for the marker directory yourself first, as the example above
does, and treat a miss as "unknown" rather than "clean".

Two things read from the source and worth flagging even though no machine here
could exercise them. The apt path runs `apt-get update` and the pacman path
runs `pacman -Sy` — both of which **mutate system state** and normally need
root, which is a surprise from a function called `get-updates`. And the yum
path shells out once per candidate package, so its cost is linear in the
number of pending updates.

## Where the two engines differ

Nowhere. The probe, the timing and the empty result were identical on Raku++
and Rakudo.

The Windows path shells `powershell ./get-updates.ps1` — a **relative** path
resolved against the current working directory — and no such script is shipped
in the distribution, so that branch cannot work as installed.

The distribution states no `auth`, and its source URL is an SSH remote rather
than a browsable one.
