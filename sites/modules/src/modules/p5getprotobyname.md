---
name: P5getprotobyname
version: 0.0.7
auth: zef:lizmat
kind: Distribution · system
summary: The POSIX protocol-database calls, returning Perl's three-field
  record of name, aliases and IANA protocol number.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5getprotobyname
source: https://github.com/lizmat/P5getprotobyname.git
---

## What it is for

A raw socket needs a protocol number, and the number for `icmp` is not
something to hard-code — `/etc/protocols` is where the system keeps the
mapping, and `getprotobyname(3)` is how you ask.

This distribution binds it, along with the reverse lookup and the enumeration,
in the shape Perl's built-ins use.

## Looking a protocol up

```raku name="lookup"
use P5getprotobyname;

for <ip icmp tcp udp> -> $p {
    my @r = getprotobyname($p);
    say sprintf('%-6s fields=%d  name=%-6s number=%d', $p, @r.elems, @r[0], @r[2]);
}
say '';
say 'scalar by name gives the number : ', getprotobyname(Scalar, 'udp');
say 'scalar by number gives the name : ', getprotobynumber(Scalar, 17);
```

```output
ip     fields=3  name=ip     number=0
icmp   fields=3  name=icmp   number=1
tcp    fields=3  name=tcp    number=6
udp    fields=3  name=udp    number=17

scalar by name gives the number : 17
scalar by number gives the name : udp
```

The record is `($name, $aliases, $number)`. The IANA numbers are fixed
everywhere, so they are safe to print; the **aliases are not** — `TCP`, `UDP`
and `ICMP` appeared here, but they come from your `/etc/protocols`.

## Enumerating

```raku name="enumerate"
use P5getprotobyname;

say 'setprotoent : ', setprotoent(0);
my $n = 0;
loop { my @e = getprotoent() or last; $n++ }
say 'endprotoent : ', endprotoent();
say 'entries walked : ', $n > 0;
```

```output
setprotoent : 1
endprotoent : 1
entries walked : True
```

## Misses

```raku name="miss"
use P5getprotobyname;

say 'unknown name   -> ', getprotobyname('nosuchproto-xyzzy').elems, ' fields';
say 'unknown number -> ', getprotobynumber(255).elems, ' fields';
say 'negative       -> ', getprotobynumber(-1).elems, ' fields';
say '';
say 'the scalar forms return an undefined value, not an exception:';
say '  ', getprotobyname(Scalar, 'nosuchproto-xyzzy').defined;
```

```output
unknown name   -> 0 fields
unknown number -> 0 fields
negative       -> 0 fields

the scalar forms return an undefined value, not an exception:
  False
```

An empty list, never an exception. That is the convention across the whole
`P5get*` family.

## The one thing to know

The scalar form of `getprotobyname` can legitimately return **0**, so the
obvious `or die` guard rejects a successful lookup.

```raku name="zero-trap"
use P5getprotobyname;

my $ip   = getprotobyname(Scalar, 'ip');
my $miss = getprotobyname(Scalar, 'nosuchproto-xyzzy');

say "'ip' is IANA protocol number 0:";
say '  value   : ', $ip;
say '  Bool    : ', ?$ip;
say '  defined : ', $ip.defined;
say '';
say 'a genuine miss:';
say '  value   : ', $miss.defined ?? $miss !! '(undefined)';
say '  Bool    : ', ?$miss;
say '  defined : ', $miss.defined;
say '';
say 'so the two are indistinguishable by truthiness.';
say 'the working guard is .defined, or //';
```

```output
'ip' is IANA protocol number 0:
  value   : 0
  Bool    : False
  defined : True

a genuine miss:
  value   : (undefined)
  Bool    : False
  defined : False

so the two are indistinguishable by truthiness.
the working guard is .defined, or //
```

IPv4's `ip` protocol is number 0, which is false. A real miss is undefined,
which is also false. `my $n = getprotobyname(Scalar, $name) or die` therefore
dies on a perfectly good lookup of `ip` — and this is machine-independent,
because protocol 0 is fixed by IANA.

Write `with getprotobyname(Scalar, $name) -> $n {…}` instead.

## Where the two engines differ

Nowhere. Every lookup, both scalar forms, the enumeration and all four
rejections produced identical output on Raku++ and Rakudo.

Negative and out-of-range numbers return an empty list rather than erroring,
which is consistent with the rest of the family and worth knowing if you are
validating user input: an invalid protocol number looks exactly like a
protocol number that is simply not in your `/etc/protocols`.
