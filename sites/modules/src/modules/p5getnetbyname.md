---
name: P5getnetbyname
version: 0.0.9
auth: zef:lizmat
kind: Distribution · system
summary: The POSIX network-database calls, returning Perl's four-field record
  of name, aliases, address type and network number.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5getnetbyname
source: https://github.com/lizmat/P5getnetbyname.git
---

## What it is for

`/etc/networks` maps names to network numbers the way `/etc/hosts` maps them
to addresses — `loopback` to 127, and whatever local names an administrator
has added. `getnetbyname(3)` is how a program reads it.

This distribution binds it, along with the reverse lookup and the enumeration,
in the shape Perl's `getnet*` built-ins use.

## Reading the database

`/etc/networks` is empty or absent on a great many current machines, so an
example has to drive off the enumeration and assert **shape**:

```raku name="enumerate"
use P5getnetbyname;

setnetent(0);
my @first = getnetent();
endnetent();

if @first {
    say 'record fields  : ', @first.elems;
    say 'name is a Str  : ', @first[0] ~~ Str;
    say 'aliases are a  : ', @first[1].^name;
    say 'addrtype is 2 (AF_INET) : ', @first[2] == 2;
    say 'net is an Int  : ', @first[3] ~~ Int;
}
else {
    say 'this machine has no network database entries';
}
say '';
say 'setnetent : ', setnetent(0);
say 'endnetent : ', endnetent();
```

```output
record fields  : 4
name is a Str  : True
aliases are a  : Array
addrtype is 2 (AF_INET) : True
net is an Int  : True

setnetent : 1
endnetent : 1
```

The record is `($name, $aliases, $addrtype, $net)`. `addrtype` 2 is `AF_INET`
on both darwin and Linux.

## Misses

```raku name="miss"
use P5getnetbyname;

say 'unknown name   -> ', getnetbyname('nosuchnet-xyzzy').elems, ' fields';
say 'unknown scalar -> ', getnetbyname(Scalar, 'nosuchnet-xyzzy').defined;
say 'bad address    -> ', getnetbyaddr(4294967295, 2).elems, ' fields';
say 'bad addrtype   -> ', getnetbyaddr(127, 99).elems, ' fields';
```

```output
unknown name   -> 0 fields
unknown scalar -> False
bad address    -> 0 fields
bad addrtype   -> 0 fields
```

An empty list, never an exception — the convention across the whole `P5get*`
family, and one that makes a miss indistinguishable from the end of an
enumeration.

## The one thing to know

The aliases field **breaks the family's convention**: it is an `Array`, not a
space-joined `Str`.

```raku name="aliases-trap"
use P5getnetbyname;
use P5getprotobyname;
use P5getservbyname;

say 'the same slot, across three siblings:';
say '  P5getprotobyname aliases : ', getprotobyname('tcp')[1].^name;
say '  P5getservbyname  aliases : ', getservbyname('http', 'tcp')[1].^name;

setnetent(0);
my @net = getnetent();
endnetent();
say '  P5getnetbyname   aliases : ', @net ?? @net[1].^name !! 'no entries here';
say '';
say 'so .words — which is right for the other two — silently produces';
say 'an Array\'s gist here rather than the alias names. Use .list.';
```

```output
the same slot, across three siblings:
  P5getprotobyname aliases : Str
  P5getservbyname  aliases : Str
  P5getnetbyname   aliases : Array

so .words — which is right for the other two — silently produces
an Array's gist here rather than the alias names. Use .list.
```

`P5getgrnam`, `P5getservbyname` and `P5getprotobyname` all call `.join(" ")`
before putting aliases into the record; this one does not. Code written
against a sibling and reused here gets an `Array` where it expected a string,
and the record arity stays 4 either way, so nothing looks wrong.

The scalar forms break the convention too: **both** of them return the
**name**, where every sibling's scalar-by-name gives an id.

## Where the two engines differ

Nowhere. Every lookup, both scalar forms, the enumeration and all four misses
produced identical output on Raku++ and Rakudo.

The thing that will vary is the **machine**, not the engine. `/etc/networks`
held `loopback` here, and `getnetbyname('localnet')` and `('arpanet')` — two
names that used to be conventional — both returned empty lists. Many current
Linux distributions ship the file empty or leave it out entirely, so any code
that looks a network up by name needs a fallback for "not present at all".
