---
name: Constants::Netinet::In
version: 0.0.1
auth: cpan:GARLANDG
kind: Distribution · system
summary: Per-platform IPPROTO and IP socket-option constants transcribed from
  netinet/in.h — and on macOS they are Blocks, not enums.
status: full
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/cpan:GARLANDG/Constants::Netinet::In
source: https://github.com/Garland-g/Constants-Netinet-In.git
---

## What it is for

`setsockopt` takes numbers: `IPPROTO_IP` is 0, `IP_ADD_MEMBERSHIP` is 12 on
this platform and something else on another. Those numbers live in a C header
and NativeCall cannot read headers, so somebody has to transcribe them. This
distribution is that transcription, branching on `$*KERNEL.name`.

## Importing

```raku name="basics"
use Constants::Netinet::In :IP, :IPPROTO;

say 'both symbols are TAG-ONLY — a plain `use` imports neither.';
say '';
say 'on this platform they arrive as: ', IP.^name;
say '  IP ~~ Block      : ', (IP ~~ Block);
say '  IPPROTO ~~ Block : ', (IPPROTO ~~ Block);
say '';
say 'so the documented IP::ADD_MEMBERSHIP spelling does not work here —';
say 'see below. Call the Block to get the enum:';
my $ip = IP.(Any);
my $proto = IPPROTO.(Any);
say '  IP enum values      : ', $ip.enums.elems;
say '  IPPROTO enum values : ', $proto.enums.elems;
```

```output
both symbols are TAG-ONLY — a plain `use` imports neither.

on this platform they arrive as: Block
  IP ~~ Block      : True
  IPPROTO ~~ Block : True

so the documented IP::ADD_MEMBERSHIP spelling does not work here —
see below. Call the Block to get the enum:
  IP enum values      : 35
  IPPROTO enum values : 107
```

## Reading the values

```raku name="values"
use Constants::Netinet::In :IP, :IPPROTO;

my $ip = IP.(Any);
my $proto = IPPROTO.(Any);

say 'IP:';
for <ADD_MEMBERSHIP DROP_MEMBERSHIP HDRINCL MULTICAST_TTL> -> $k {
    say sprintf('  %-18s %s', $k, $ip.enums{$k} // '(absent)');
}
say '';
say 'IPPROTO:';
for <IP ICMP TCP UDP RAW> -> $k {
    say sprintf('  %-18s %s', $k, $proto.enums{$k} // '(absent)');
}
say '';
say 'the first ten IP names, sorted:';
say '  ', $ip.enums.keys.sort.head(10).join(' ');
```

```output
IP:
  ADD_MEMBERSHIP     12
  DROP_MEMBERSHIP    13
  HDRINCL            2
  MULTICAST_TTL      10

IPPROTO:
  IP                 0
  ICMP               1
  TCP                6
  UDP                17
  RAW                255

the first ten IP names, sorted:
  ADD_MEMBERSHIP ADD_SOURCE_MEMBERSHIP BLOCK_SOURCE BOUND_IF DROP_MEMBERSHIP DROP_SOURCE_MEMBERSHIP FAITH HDRINCL IPSEC_POLICY MSFILTER
```

## The one thing to know

On macOS the module exports two `Block` objects, not two enums — the constants
do not exist.

```raku name="blocks"
use Constants::Netinet::In :IP, :IPPROTO;

say 'every platform branch is written  ?? do { my enum … ; NAME }';
say 'except the final !!, which is the macOS one and omits the `do`:';
say '';
say '  447: }';
say '  448: !! { #macosx';
say '';
say 'a bare { … } in term position is a Block LITERAL, so the body never';
say 'runs and `constant IP` is bound to the closure itself.';
say '';
say '  IP.^name   : ', IP.^name;
my $r = try IP.enums;
say '  IP.enums   : ', $r ?? 'works' !! 'No such method for a Block';
say '';
say 'this is the LAST branch in the chain, so any unrecognised OS gets it';
say 'too. Nothing catches it: the distribution ships zero test files.';
say '';
say 'the workaround, and it is engine-sensitive:';
say '  IP.()      works on Raku++ (block arity 0/0) and dies on Rakudo';
say '  IP.(Any)   works on BOTH — use this one';
say '';
say 'whether two calls mint the same enum type is engine-dependent, so';
say 'call it once and keep the result:';
my $IP = IP.(Any);
say '  $IP.enums.elems = ', $IP.enums.elems;
```

```output
every platform branch is written  ?? do { my enum … ; NAME }
except the final !!, which is the macOS one and omits the `do`:

  447: }
  448: !! { #macosx

a bare { … } in term position is a Block LITERAL, so the body never
runs and `constant IP` is bound to the closure itself.

  IP.^name   : Block
  IP.enums   : No such method for a Block

this is the LAST branch in the chain, so any unrecognised OS gets it
too. Nothing catches it: the distribution ships zero test files.

the workaround, and it is engine-sensitive:
  IP.()      works on Raku++ (block arity 0/0) and dies on Rakudo
  IP.(Any)   works on BOTH — use this one

whether two calls mint the same enum type is engine-dependent, so
call it once and keep the result:
  $IP.enums.elems = 35
```

## Duplicate values

```raku name="duplicates"
use Constants::Netinet::In :IP, :IPPROTO;

my $ip = IP.(Any);
my %by-value;
for $ip.enums.kv -> $k, $v { %by-value{$v}.push($k) }
say 'IP values held by more than one name:';
for %by-value.keys.sort({ .Int }) -> $v {
    next unless %by-value{$v}.elems > 1;
    say sprintf('  %-4s %s', $v, %by-value{$v}.sort.join(' / '));
}
say '';
say 'reverse lookup is therefore lossy and arbitrary — $ip(26) returns';
say 'one of the two names and the other is unreachable. Go name to number,';
say 'never the other way.';
```

```output
IP values held by more than one name:
  7    RECVDSTADDR / SENDSRCADDR
  26   PKTINFO / RECVPKTINFO
  27   RECVORIGDSTADDR / RECVTOS

reverse lookup is therefore lossy and arbitrary — $ip(26) returns
one of the two names and the other is unreachable. Go name to number,
never the other way.
```

## Where the two engines differ

The `IP.()` invocation above, and the leak: after a plain `use` with no tags,
Raku++ still makes `IP` and `IPPROTO` visible while Rakudo correctly does not.
Write the tags, and use `.(Any)`.

```raku name="portable"
use Constants::Netinet::In :IP, :IPPROTO;

# call each Block once, keep the enum, and read names from it
my $IP    = IP.(Any);
my $PROTO = IPPROTO.(Any);

sub ip-option(Str $name) {
    $IP.enums{$name} // die "no IP option named $name on {$*KERNEL.name}"
}
say 'ip-option("ADD_MEMBERSHIP") = ', ip-option('ADD_MEMBERSHIP');
my $e = try ip-option('NO_SUCH_OPTION');
say 'ip-option("NO_SUCH_OPTION") = ', $! ?? $!.message !! 'found';
say '';
say 'the enum VALUES are never exported bare — even where the branch';
say 'works you get only the two type names, and ADD_MEMBERSHIP on its own';
say 'is never in scope.';
say '';
say 'the distribution is not in the zef index; it resolves from the REA';
say 'archive, whose index path carries no checksum.';
```

```output
ip-option("ADD_MEMBERSHIP") = 12
ip-option("NO_SUCH_OPTION") = no IP option named NO_SUCH_OPTION on darwin

the enum VALUES are never exported bare — even where the branch
works you get only the two type names, and ADD_MEMBERSHIP on its own
is never in scope.

the distribution is not in the zef index; it resolves from the REA
archive, whose index path carries no checksum.
```
