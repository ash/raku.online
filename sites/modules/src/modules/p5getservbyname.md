---
name: P5getservbyname
version: 0.0.8
auth: zef:lizmat
kind: Distribution · system
summary: The POSIX service-database calls, shaped so the return value matches
  what Perl's built-ins of the same name hand back, with ports byte-swapped
  into host order for you.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:lizmat/P5getservbyname
source: https://github.com/lizmat/P5getservbyname.git
---

## What it is for

`/etc/services` maps service names to port numbers, and `getservbyname(3)` is
how a program asks about it without parsing the file. Raku has no built-in for
it, so anything that wants to resolve `https` to 443 the way the operating
system would has to bind the C call.

This distribution binds it, and shapes the answer the way Perl's `getserv*`
built-ins do — which matters if you are porting Perl, and is a reasonable
shape regardless.

## Looking a service up

```raku name="lookup"
use P5getservbyname;

for <ssh http https smtp domain> -> $name {
    my @r = getservbyname($name, 'tcp');
    say sprintf('%-8s/tcp  fields=%d  name=%-8s port=%-5d proto=%s',
        $name, @r.elems, @r[0], @r[2], @r[3]);
}
```

```output
ssh     /tcp  fields=4  name=ssh      port=22    proto=tcp
http    /tcp  fields=4  name=http     port=80    proto=tcp
https   /tcp  fields=4  name=https    port=443   proto=tcp
smtp    /tcp  fields=4  name=smtp     port=25    proto=tcp
domain  /tcp  fields=4  name=domain   port=53    proto=tcp
```

The record is `($name, $aliases, $port, $proto)`, in Perl's order. The IANA
numbers are the same on every machine, which is why they are safe to print;
the **aliases are not** — they come from your `/etc/services` and vary.

The port is already in host byte order. The module byte-swaps in both
directions, so you never see network order.

## Scalar context

```raku name="scalar"
use P5getservbyname;

say 'by name, gives the port : ', getservbyname(Scalar, 'https', 'tcp');
say 'by port, gives the name : ', getservbyport(Scalar, 443, 'tcp');
say '';
say 'the list forms of the same two calls:';
say '  getservbyname("https","tcp")[2] = ', getservbyname('https', 'tcp')[2];
say '  getservbyport(443,"tcp")[0]     = ', getservbyport(443, 'tcp')[0];
```

```output
by name, gives the port : 443
by port, gives the name : https

the list forms of the same two calls:
  getservbyname("https","tcp")[2] = 443
  getservbyport(443,"tcp")[0]     = https
```

Perl asks for a scalar by calling in scalar context; Raku has no such thing,
so the module takes the **`Scalar` type object** as an extra first argument.
The result is asymmetric by design: lookup by name gives you the id, lookup by
id gives you the name.

## Enumerating

```raku name="enumerate"
use P5getservbyname;

say 'setservent : ', setservent(1);
my ($n, $widest) = 0, 0;
loop {
    my @e = getservent() or last;
    $n++;
    $widest = @e.elems if @e.elems > $widest;
}
say 'endservent : ', endservent();
say 'entries walked : ', $n > 0;
say 'every entry had four fields : ', $widest == 4;
```

```output
setservent : 1
endservent : 1
entries walked : True
every entry had four fields : True
```

The sentinel for "no more entries" is the same empty list a failed lookup
gives, so one test ends the loop — and the two cases are indistinguishable.

## The one thing to know

The protocol argument is mandatory and must match exactly. There is no "any
protocol" lookup.

```raku name="proto-trap"
use P5getservbyname;

for 'tcp', 'TCP', '' -> $proto {
    say sprintf('getservbyname("ssh", %-7s) -> %d field(s)',
        $proto.raku, getservbyname('ssh', $proto).elems);
}
say '';
say 'in C you pass NULL for proto to match any protocol.';
say 'here the parameter is Str(), so the only thing you can supply';
say 'is a string — and the empty string matches nothing.';
```

```output
getservbyname("ssh", "tcp"  ) -> 4 field(s)
getservbyname("ssh", "TCP"  ) -> 0 field(s)
getservbyname("ssh", ""     ) -> 0 field(s)

in C you pass NULL for proto to match any protocol.
here the parameter is Str(), so the only thing you can supply
is a string — and the empty string matches nothing.
```

The lookup is also **case-sensitive**: `'TCP'` returns nothing. So a protocol
name arriving from a configuration file has to be lower-cased before it gets
here, and there is no way to ask the question C lets you ask.

## Where the two engines differ

Nowhere. Every lookup, every scalar form, the enumeration and all three
rejections produced identical output on Raku++ and Rakudo.

The convention shared by the whole `P5get*` family is worth stating once,
because it is the thing that catches people. **A failed lookup returns an
empty list, never an exception** — so destructuring into four variables leaves
every one of them undefined, and the natural Perl transcription that reads
field 2 of the result gets `Any` rather than an error. Test the *list*, never
a field:

```raku name="miss"
use P5getservbyname;

my @miss = getservbyname('nosuchservice-xyzzy', 'tcp');
say 'list form elems   : ', @miss.elems;
say 'scalar form       : ', getservbyname(Scalar, 'nosuchservice-xyzzy', 'tcp').defined;
say '';
my ($name, $aliases, $port, $proto) = getservbyname('nosuchservice-xyzzy', 'tcp');
say 'port after a failed lookup : ', $port.defined ?? $port !! 'undefined';
say 'the right test is on the list : ',
    ?getservbyname('nosuchservice-xyzzy', 'tcp').elems;
```

```output
list form elems   : 0
scalar form       : False

port after a failed lookup : undefined
the right test is on the list : False
```
