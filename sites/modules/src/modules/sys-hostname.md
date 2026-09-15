---
name: Sys::Hostname
version: 0.0.11
auth: zef:lizmat
kind: Distribution · system
summary: A three-line shim exporting `hostname()` — and the one `Kernel`
  method that survives being called on the type object.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/Sys::Hostname
source: https://codeberg.org/lizmat/Sys-Hostname.git
---

## What it is for

Perl 5 has `Sys::Hostname`, and code being ported reaches for the same name.
Raku already answers the question as `$*KERNEL.hostname`; this distribution
is the familiar spelling over it, and nothing more — no fallbacks, no caching,
no short/long-name choice.

## Using it

```raku name="basics"
use Sys::Hostname;

my $h = hostname();
say 'type            : ', $h.WHAT.^name;
say 'defined         : ', $h.defined;
say 'non-empty       : ', $h.chars > 0;
say 'no whitespace   : ', !($h ~~ /\s/);
say 'hostname-shaped : ', so $h ~~ /^ <[\w.-]>+ $/;
say '';
say 'stable across two calls      : ', hostname() eq hostname();
say 'same as $*KERNEL.hostname    : ', $h eq $*KERNEL.hostname;
say '';
say 'nothing above prints the machine`s name — every line is a property';
say 'that holds wherever you run it.';
```

```output
type            : Str
defined         : True
non-empty       : True
no whitespace   : True
hostname-shaped : True

stable across two calls      : True
same as $*KERNEL.hostname    : True

nothing above prints the machine`s name — every line is a property
that holds wherever you run it.
```

`hostname` takes no arguments:

```raku name="arity"
use Sys::Hostname;

say 'arity / count : ', &hostname.arity, ' / ', &hostname.count;
say 'signature     : ', &hostname.signature.gist;
say '';
my $r = try &hostname('x');
say 'calling it with an argument -> ', $! ?? 'refused' !! $r;
say '';
say 'a direct hostname("x") is a COMPILE-time error on Rakudo ("Calling';
say 'hostname(Str) will never work with declared signature ()") and only';
say 'a run-time one on Raku++, so `try` helps on one engine and not the';
say 'other. The refusal is the same either way.';
```

```output
arity / count : 0 / 0
signature     : ()

calling it with an argument -> refused

a direct hostname("x") is a COMPILE-time error on Rakudo ("Calling
hostname(Str) will never work with declared signature ()") and only
a run-time one on Raku++, so `try` helps on one engine and not the
other. The refusal is the same either way.
```

## The one thing to know

The body is `Kernel.hostname` — on the **type object**, not on `$*KERNEL`.
That works, and it is the only one of `Kernel`'s informational methods that
does.

```raku name="typeobject"
use Sys::Hostname;

say 'Kernel.hostname on the type object works : ',
    (try Kernel.hostname).defined;
say '';
say '  Kernel.name / .arch / .bits on the type object -> engine-dependent';
say '';
say 'under Rakudo, name, arch and bits all die on a type object with';
say 'X::AdHoc while hostname succeeds; under Raku++ all four work, so the';
say 'difference is invisible there.';
say '';
say 'anyone "simplifying" this module by writing Kernel.name beside';
say 'Kernel.hostname gets a crash on Rakudo only. Use $*KERNEL for';
say 'everything except the one method this module already wraps:';
say '  $*KERNEL.name works everywhere : ', ($*KERNEL.name.chars > 0);
```

```output
Kernel.hostname on the type object works : True

  Kernel.name / .arch / .bits on the type object -> engine-dependent

under Rakudo, name, arch and bits all die on a type object with
X::AdHoc while hostname succeeds; under Raku++ all four work, so the
difference is invisible there.

anyone "simplifying" this module by writing Kernel.name beside
Kernel.hostname gets a crash on Rakudo only. Use $*KERNEL for
everything except the one method this module already wraps:
  $*KERNEL.name works everywhere : True
```

## Where the two engines differ

Only in introspection and in when the arity error is reported. `&hostname.signature.returns`
is `Mu` on both, so a `Str:D` constraint at your call site is unchecked at
compile time; under Rakudo `Kernel.^lookup('hostname').signature` reads
`(Kernel $:: *%_ --> Str:D)` and under Raku++ the same lookup reports `()`.

```raku name="portable"
use Sys::Hostname;

# if you want the guarantee the signature does not give you
sub host(--> Str:D) { hostname() // die 'no hostname available' }

my $h = host();
say 'host() returns a defined Str : ', ($h ~~ Str:D);
say 'and it is the same value     : ', $h eq $*KERNEL.hostname;
say '';
say 'the distribution is three lines long and has no dependencies, so';
say 'there is nothing else to know about it — which is the point.';
```

```output
host() returns a defined Str : True
and it is the same value     : True

the distribution is three lines long and has no dependencies, so
there is nothing else to know about it — which is the point.
```
