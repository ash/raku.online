---
name: P5getpwnam
version: 0.0.11
auth: zef:lizmat
kind: Distribution · system
summary: The POSIX password-database calls, reshaping the platform's struct
  passwd into the field order Perl's getpw built-ins use.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5getpwnam
source: https://github.com/lizmat/P5getpwnam.git
---

## What it is for

Resolving a user name to a uid, or a uid to a home directory, means reading
the password database — and `struct passwd` has a different layout on BSD, on
Linux and on generic Unix, so a NativeCall binding has to pick one at load
time.

This distribution does that, and presents the result in Perl's field order.

## Looking a user up

```raku name="lookup"
use P5getpwnam;

# uid 0 exists on every POSIX machine. Nothing here prints a name,
# a home directory or a shell.
my @p = getpwuid(0);
say 'fields            : ', @p.elems;
say 'name is defined   : ', @p[0].defined;
say 'uid               : ', @p[2];
say 'gid is an Int     : ', @p[3] ~~ Int;
say 'home looks absolute : ', @p[7].starts-with('/');
say 'shell is defined  : ', @p[8].defined;
say '';
say 'scalar by uid gives the name : ', getpwuid(Scalar, 0) eqv @p[0];
say 'scalar by name gives the uid : ', getpwnam(Scalar, @p[0]);
```

```output
fields            : 10
name is defined   : True
uid               : 0
gid is an Int     : True
home looks absolute : True
shell is defined  : True

scalar by uid gives the name : True
scalar by name gives the uid : 0
```

`getlogin()` is bound too, as a direct native call.

## Enumerating

```raku name="enumerate"
use P5getpwnam;

say 'setpwent : ', setpwent();
my $n = 0;
loop { my @e = getpwent() or last; $n++ }
say 'endpwent : ', endpwent();
say 'entries walked : ', $n > 0;
```

```output
setpwent : 1
endpwent : 1
entries walked : True
```

The same empty-list sentinel as the rest of the `P5get*` family: a failed
lookup and the end of the enumeration are indistinguishable.

## The one thing to know

The record's **arity is not portable**, and two of its fields are hard-coded
fillers.

```raku name="arity-trap"
use P5getpwnam;

my @p = getpwuid(0);
say 'this kernel : ', $*KERNEL.name;
say 'record length here : ', @p.elems;
say '';
say 'on darwin and freebsd the list is 10 long:';
say '  ($name, $passwd, $uid, $gid, $quota, $comment, $gecos, $dir, $shell, $expire)';
say 'on linux and generic unix it is 9 — the trailing $expire is absent.';
say '';
say 'so the same destructuring assignment binds different things per platform.';
say '';
say 'and fields 4 and 5 are literals the module writes in:';
say '  field 4 (quota)   is always : ', @p[4].raku;
say '  field 5 (comment) is always : ', @p[5].raku;
say '  the real GECOS text is field 6, one later than a Perl one-liner';
say '  that says "the fifth element is the comment" would reach for.';
```

```output
this kernel : darwin
record length here : 10

on darwin and freebsd the list is 10 long:
  ($name, $passwd, $uid, $gid, $quota, $comment, $gecos, $dir, $shell, $expire)
on linux and generic unix it is 9 — the trailing $expire is absent.

so the same destructuring assignment binds different things per platform.

and fields 4 and 5 are literals the module writes in:
  field 4 (quota)   is always : 0
  field 5 (comment) is always : ""
  the real GECOS text is field 6, one later than a Perl one-liner
  that says "the fifth element is the comment" would reach for.
```

Walking the whole database finds no entry anywhere with a non-zero field 4 or
a non-empty field 5 — they are not read from the operating system at all.

Never write `getpwuid(0).elems` into a test, and index the GECOS field as 6.

## Where the two engines differ

Nowhere. Every lookup, both scalar forms, the enumeration and the field
analysis produced identical output on Raku++ and Rakudo.

Two things to keep out of any example that has to run anywhere: **uid
4294967294 is not a safe "absent uid"** — it is `nobody` on macOS — and the
record arity, as above. `getlogin()` returned a defined `Str` even with no
terminal attached, which is not something to rely on.
