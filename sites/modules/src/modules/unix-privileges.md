---
name: UNIX::Privileges
version: 0.1.6
auth: zef:jonathanstowe
kind: Distribution · system
summary: Look a user or group up, drop to it in the correct order, change a
  path's owner, and chroot — over a small bundled C helper.
status: full
suite: 7 files, green
tested: 2026-09-15
license: ISC
depends: none at runtime
raku-land: https://raku.land/zef:jonathanstowe/UNIX::Privileges
source: https://github.com/jonathanstowe/raku-unix-privileges.git
---

## What it is for

A daemon started as root has to give up that privilege before it does anything
else, and the order matters: drop the supplementary groups, then the group,
then the user, because once you are no longer root you cannot change your
group. Getting that sequence wrong is a security bug that looks like working
code.

This distribution wraps a small C helper that does the fiddly parts correctly.

## Looking a user up

```raku name="userinfo"
use UNIX::Privileges :USER;

# root is uid 0 on every POSIX machine. Nothing here prints a login,
# a home directory or a shell.
my $u = userinfo('root');
say 'type        : ', $u.^name;
say 'attributes  : ', $u.^attributes.map(*.name).sort.join(' ');
say 'uid         : ', $u.uid;
say 'gid is Int  : ', $u.gid ~~ Int;
say 'login is Str: ', $u.login ~~ Str;
say 'home is absolute : ', $u.home.starts-with('/');
say '';
my $g = groupinfo('daemon');
say 'group type  : ', $g.^name;
say 'group attrs : ', $g.^attributes.map(*.name).sort.join(' ');
say 'gid is Int  : ', $g.gid ~~ Int;
```

```output
type        : UNIX::Privileges::User
attributes  : $!gid $!home $!login $!shell $!uid
uid         : 0
gid is Int  : True
login is Str: True
home is absolute : True

group type  : UNIX::Privileges::Group
group attrs : $!gid $!name
gid is Int  : True
```

Those two are the only routines this page exercises. `drop`, `chown` and
`chroot` are deliberately not run: `drop` changes the process's uid and gid
**irreversibly**, `chroot` changes the process root and then `chdir`s to it,
and `chown` writes ownership metadata to a path.

## The import tags

```raku name="tags"
use UNIX::Privileges;

say 'a plain `use` imports nothing at all.';
say 'the full name still works:';
say '  UNIX::Privileges::userinfo("root").uid = ',
    UNIX::Privileges::userinfo('root').uid;
say '';
say 'the three tags:';
say '  :USER  gives userinfo and groupinfo';
say '  :CH    gives chown and chroot';
say '  :ALL   gives those four plus drop';
```

```output
a plain `use` imports nothing at all.
the full name still works:
  UNIX::Privileges::userinfo("root").uid = 0

the three tags:
  :USER  gives userinfo and groupinfo
  :CH    gives chown and chroot
  :ALL   gives those four plus drop
```

There is **no `:DEFAULT`**. This is exactly the class of surprise where a
reader copies a call out of a synopsis, forgets the tag, and gets an
undeclared-routine error with no hint that a tag is what is missing.

## When the lookup fails

```raku name="miss"
use UNIX::Privileges :USER;

for 'nosuchuser-xyzzy', 'nosuchgroup-xyzzy' -> $n {
    my $r = try $n.starts-with('nosuchuser') ?? userinfo($n) !! groupinfo($n);
    say sprintf('%-20s -> %s', $n, $! ?? $!.message !! 'found');
}
```

```output
nosuchuser-xyzzy     -> fatal: could not get user info: no such user
nosuchgroup-xyzzy    -> fatal: could not get user info: no such user
```

Both report "could not get **user** info", including the group lookup — the C
helper reuses one message for both.

## The one thing to know

Three of the five routines are irreversible or system-altering, and the
interface does not distinguish them from the two that only report.

`drop($user)` changes the process's uid and gid, and a non-root process cannot
change back. `chroot($dir)` changes the process root and then `chdir`s to `/`
inside it. `chown($user, $path)` writes filesystem metadata. They sit in the
same export list as `userinfo` and `groupinfo`, which do nothing but read, and
nothing in the naming separates the two kinds.

Import `:USER` when you only need the lookups, and reach for `:ALL` only at
the point where you actually mean to give up privilege.

## Where the two engines differ

On when an undeclared routine is reported, and on what `:CH` collides with.

With no tag, Rakudo refuses to compile a file that calls `userinfo` while
Raku++ runs until it reaches the call — so a rakupp-developed program with the
call in a rarely taken branch will not compile on Rakudo at all.

And importing `:CH` **shadows Rakudo's core `chown`** with a three-candidate
set of a different signature. Raku++ has no core `chown`, so the collision
does not arise there — which means the same import is silently more disruptive
on one engine.

One more difference, in noise: Rakudo emits a deprecation report at exit on
every run that loads this module, from the module's use of
`Distribution::Resource.Str`. Anything capturing stderr will see it.

The module's `groupinfo` also declares its native call with a `User` parameter
while passing a `Group`; NativeCall does not enforce it and the call works,
but the declaration is wrong.
