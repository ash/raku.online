---
name: P5getgrnam
version: 0.0.10
auth: zef:lizmat
kind: Distribution · system
summary: The POSIX group-database calls, shaped so the return value matches
  what Perl's built-ins of the same name hand back.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5getgrnam
source: https://github.com/lizmat/P5getgrnam.git
---

## What it is for

Turning a group name into a gid, or a gid back into a name, is what
`getgrnam(3)` and `getgrgid(3)` are for — and Raku has no built-in for either.
Anything that sets group ownership, checks membership, or reports on a file's
group needs them.

This distribution binds them, and shapes the answer the way Perl's `getgr*`
built-ins do.

## Looking a group up

```raku name="lookup"
use P5getgrnam;

# gid 0 is the superuser group on every POSIX machine; its NAME is not
# portable (wheel on BSD, root on Linux), so this checks shape.
my @g = getgrgid(0);
say 'fields             : ', @g.elems;
say 'name is a non-empty Str : ', @g[0].defined && @g[0].chars > 0;
say 'gid                : ', @g[2];
say 'members field is a : ', @g[3].^name;
say '';
say 'scalar by gid gives the name : ', getgrgid(Scalar, 0) eqv @g[0];
say 'scalar by name gives the gid : ', getgrnam(Scalar, @g[0]);
```

```output
fields             : 4
name is a non-empty Str : True
gid                : 0
members field is a : Str

scalar by gid gives the name : True
scalar by name gives the gid : 0
```

The record is `($name, $passwd, $gid, $members)` in Perl's order, and
`$members` is a **space-joined `Str`**, not a list — `.words` gets you the
names.

Perl asks for a scalar by calling in scalar context; Raku has no such thing,
so the module takes the `Scalar` type object as an extra first argument. The
result is asymmetric by design: by name gives the id, by id gives the name.

## Walking the database

```raku name="enumerate"
use P5getgrnam;

say 'setgrent : ', setgrent();
my ($n, $widest) = 0, 0;
loop {
    my @e = getgrent() or last;
    $n++;
    $widest = @e.elems if @e.elems > $widest;
}
say 'endgrent : ', endgrent();
say '';
say 'entries walked         : ', $n > 0;
say 'every entry had 4 fields : ', $widest == 4;
```

```output
setgrent : 1
endgrent : 1

entries walked         : True
every entry had 4 fields : True
```

The enumeration is re-runnable — call `setgrent` again and you start over.

## The one thing to know

A failed lookup returns an **empty list**, not a list of undefined values and
not an exception.

```raku name="miss-trap"
use P5getgrnam;

my @miss = getgrnam('nosuchgroup-xyzzy');
say 'the list form has ', @miss.elems, ' elements';
say 'the scalar form is defined : ', getgrnam(Scalar, 'nosuchgroup-xyzzy').defined;
say 'and nothing was thrown';
say '';
say 'so the natural Perl transcription leaves every variable undefined:';
my ($name, $passwd, $gid, $members) = getgrnam('nosuchgroup-xyzzy');
say '  gid after a failed lookup : ', $gid.defined ?? $gid !! 'undefined';
say '';
say 'the test has to be on the LIST:';
say '  found : ', ?getgrnam('nosuchgroup-xyzzy').elems;
```

```output
the list form has 0 elements
the scalar form is defined : False
and nothing was thrown

so the natural Perl transcription leaves every variable undefined:
  gid after a failed lookup : undefined

the test has to be on the LIST:
  found : False
```

There is no `Failure`, no `die`, and — worse — no way to distinguish "group
absent" from "end of enumeration", because `getgrent` uses the very same empty
list as its sentinel.

Test the list, never a field.

## Where the two engines differ

Nowhere. Every lookup, both scalar forms, the enumeration and the miss
produced identical output on Raku++ and Rakudo.

Two notes on the family convention. The scalar forms return `Nil`, which
becomes `Any` the moment you store it in a `$` container — so `.raku` on the
return value and `.raku` on the variable say different things.

And `$members` being a joined `Str` is **not** shared across the family:
`P5getnetbyname` hands its aliases back as a live `Array` in the same slot.
Code written against one sibling and reused on another gets the wrong type,
and `.words` on an `Array` silently produces its gist.
