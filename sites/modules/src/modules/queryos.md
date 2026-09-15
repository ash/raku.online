---
name: QueryOS
version: 0.1.2
auth: zef:tbrowder
kind: Distribution · system
summary: Identify the host operating system and split its version string into
  parts, so a program can branch on platform without parsing $*DISTRO by hand.
status: partial
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:tbrowder/QueryOS
source: https://github.com/tbrowder/QueryOS.git
---

## What it is for

`$*DISTRO` tells you a name and a version string and leaves the interpretation
to you — and the interpretation differs per platform, because macOS versions
look nothing like Debian codenames.

This distribution wraps that into an object with three predicates and a set of
version parts, so a platform branch reads as a question rather than a string
comparison.

## Asking about the host

Anything this prints is specific to the machine it runs on, so the example
asserts **shape**:

```raku name="os"
use QueryOS;

my $os = OS.new;

say 'class                : ', $os.^name;
say 'name is a Str        : ', $os.name ~~ Str;
say 'version is defined   : ', $os.version.defined;
say 'vnum is Numeric      : ', $os.vnum ~~ Numeric;
say '';
say 'exactly one predicate is true : ',
    ([+] $os.is-linux, $os.is-macos, $os.is-windows) == 1;
say 'all three return Bool         : ',
    ($os.is-linux ~~ Bool) && ($os.is-macos ~~ Bool) && ($os.is-windows ~~ Bool);
```

```output
class                : QueryOS::OS
name is a Str        : True
version is defined   : True
vnum is Numeric      : True

exactly one predicate is true : True
all three return Bool         : True
```

Constructing an `OS` on macOS prints `WARNING: OS macos is not supported.
Please file an issue.` to **stderr** — unconditionally, once per construction.
It is not visible above because the gate compares stdout, and it will pollute
the output of any tool that builds one in a loop.

## Splitting a version string

```raku name="parts"
use QueryOS;

for '10.15.7', '22.6', '1.0.1.buster', 'bookworm', '' -> $v {
    my %p = os-version-parts($v);
    say sprintf('%-14s => %s', $v.raku,
        %p.keys.sort.map({ "$_={%p{$_}.raku}" }).join(' '));
}
```

```output
"10.15.7"      => version-name="" version-serial="10.15.7" vnum=10.157e0 vshort-name=""
"22.6"         => version-name="" version-serial="22.6" vnum=22.6e0 vshort-name=""
"1.0.1.buster" => version-name="buster" version-serial="1.0.1" vnum=1.01e0 vshort-name="buster"
"bookworm"     => version-name="bookworm" version-serial=0 vnum=0e0 vshort-name="bookworm"
""             => version-name="" version-serial=0 vnum=0e0 vshort-name=""
```

`os-version-parts` is exported and works on any string, so you can use it
without constructing an `OS` at all. Note `version-serial` is a `Str` for
numeric-looking versions and the `Int` `0` for named ones, so its type is not
stable.

## The one thing to know

`vnum` is a `Num` built by deleting the dots after the first, so ordering by it
is wrong.

```raku name="vnum-trap"
use QueryOS;

for '10.2', '10.9', '10.15', '10.15.7', '11.0' -> $v {
    say sprintf('  %-9s vnum = %s', $v, os-version-parts($v)<vnum>);
}
say '';
my @vers = <10.2 10.9 10.15 10.15.7 11.0>;
say 'sorted by vnum  : ', @vers.sort({ os-version-parts($_)<vnum> }).join(' ');
say 'true chronology : 10.2 10.9 10.15 10.15.7 11.0';
```

```output
  10.2      vnum = 10.2
  10.9      vnum = 10.9
  10.15     vnum = 10.15
  10.15.7   vnum = 10.157
  11.0      vnum = 11

sorted by vnum  : 10.15 10.15.7 10.2 10.9 11.0
true chronology : 10.2 10.9 10.15 10.15.7 11.0
```

`10.15` becomes `10.15`, `10.2` becomes `10.2`, and numerically `10.2` is
greater — so a version gate written as `if $os.vnum >= 10.15` treats macOS
10.2 from 2002 as newer than 10.15 from 2019. Sorting five real version
strings by `vnum` produces an order that is neither ascending nor descending
in any meaningful sense.

The `Num` also loses precision by construction: `10.15.7` collapses to
`10.157`.

Compare `version-serial` component by component instead, or use Raku's own
`Version` type, which knows how to order these.

## Where the two engines differ

Nowhere. Every shape assertion, every version split and the whole broken
ordering were identical on Raku++ and Rakudo, including the stderr warning on
macOS.

One thing to know before you reach for the rest of the interface: `run-cli`
is exported and **shells out**. It is not a pure query, despite sitting in the
same export list as `os-version-parts`.
