---
title: Files, digests & class extensions
slug: files-and-utils
status: full
browser: false
browser-why: needs installed module distributions and the filesystem
rakulib: battery
order: 40
summary: File::Temp, File::Find, Digest::SHA1, HMAC, UUID, OO::Monitors and Method::Also under Raku++.
---

Filesystem helpers, hashing, and two object-system extensions — all running
unmodified. Output verified against the interpreter and Rakudo at build time.

## File::Temp and File::Find

`tempfile` hands you a path and an open handle; `find` walks a directory tree
with filters. Together they make a self-cleaning example.

```raku
use File::Temp;
use File::Find;

my $dir = tempdir;
for <alpha.txt beta.txt gamma.log> -> $name {
    $dir.IO.add($name).spurt("content of $name");
}

my @found = find(:$dir, name => /'.txt' $/);
say @found.elems;
say @found.map(*.basename).sort.join(', ');
say $dir.IO.add('gamma.log').slurp;
```
```output
2
alpha.txt, beta.txt
content of gamma.log
```

## Digest::SHA1 and HMAC

Pure-Raku hashing — no OpenSSL needed. The digest comes back as a `Blob`;
format it yourself.

```raku
use Digest::SHA1;
say sha1('abc').list.map(*.fmt('%02x')).join;
```
```output
a9993e364706816aba3e25717850c26c9cd0d89d
```

```raku
use HMAC;
use Digest::SHA1;
say hmac(key => 'key'.encode, msg => 'message'.encode,
         hash => &sha1, block-size => 64).list.map(*.fmt('%02x')).join;
```
```output
2088df74d5f2146b48146caf4965377e9d0be3a4
```

## UUID

Random (version 4) UUIDs with the standard dashed formatting — 36 characters,
the version digit in its slot.

```raku
use UUID;

my $u = UUID.new(:version(4));
say $u.Str.chars;
say $u.Str.comb('-').elems;
say $u.Str.substr(14, 1);
```
```output
36
4
4
```

## OO::Monitors

`monitor` is a class whose method calls are mutually excluded — a
thread-safety primitive as a declarator.

```raku
use OO::Monitors;
monitor Counter {
    has $.n = 0;
    method bump { ++$!n }
}
my $c = Counter.new;
$c.bump for ^3;
say $c.n;
```
```output
3
```

## Method::Also

One method, several names — `is also<…>` registers extra method names while
the class composes.

```raku
use Method::Also;

class Point {
    has $.x; has $.y;
    method magnitude() is also<abs2> { sqrt($!x² + $!y²) }
}
my $p = Point.new(:x(3), :y(4));
say $p.magnitude;
say $p.abs2;
```
```output
5
5
```
