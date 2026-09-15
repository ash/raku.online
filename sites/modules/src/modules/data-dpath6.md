---
name: Data::DPath6
version: 0.0.2
auth: zef:renormalist
kind: Distribution · placeholders
summary: A placeholder release — the whole executable content is one method
  that returns 42.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:renormalist/Data::DPath6
source: https://github.com/renormalist/raku-Data-DPath6.git
---

## What it is for

Perl 5's `Data::DPath` is an XPath-like query language for nested data: you
write `//foo/*/bar` and get back the matching values. The name here promises a
Raku port of that.

What is installed is a placeholder. The distribution's entire executable
content is a class with one method, and the remaining sixty-seven lines are
documentation of what the module will do.

## The whole API

```raku name="whole-api"
use Data::DPath6;

say 'the type            : ', Data::DPath6.^name;
say 'its methods         : ',
    Data::DPath6.^methods(:local).map(*.name).grep(* ne 'POPULATE').sort.join(', ');
say 'its attributes      : ', Data::DPath6.^attributes(:local).elems;
say '';
say 'Data::DPath6.hello  : ', Data::DPath6.hello;
say 'on an instance      : ', Data::DPath6.new.hello;
say '';
say 'nothing is exported : the class name is what you get.';
```

```output
the type            : Data::DPath6
its methods         : hello
its attributes      : 0

Data::DPath6.hello  : 42
on an instance      : 42

nothing is exported : the class name is what you get.
```

## The one thing to know

It installs cleanly, its suite is green, and it does not have the feature its
name promises.

```raku name="not-there"
use Data::DPath6;

for <dpath dpathi search query select> -> $m {
    say sprintf('  .^can(%-8s) : %d', $m.raku, Data::DPath6.^can($m).elems);
}
say '';
say 'there is no path language, no data selection, nothing. A green test';
say 'suite here is evidence of packaging, not of function.';
say '';
say 'that is worth stating plainly because the failure mode is quiet:';
say '`zef install Data::DPath6` succeeds, `use Data::DPath6` succeeds,';
say 'and the first call you actually wanted is a method-not-found.';
```

```output
  .^can("dpath" ) : 0
  .^can("dpathi") : 0
  .^can("search") : 0
  .^can("query" ) : 0
  .^can("select") : 0

there is no path language, no data selection, nothing. A green test
suite here is evidence of packaging, not of function.

that is worth stating plainly because the failure mode is quiet:
`zef install Data::DPath6` succeeds, `use Data::DPath6` succeeds,
and the first call you actually wanted is a method-not-found.
```

## What to use instead

```raku name="alternative"
say 'Raku`s own postcircumfix and Hash/Array methods cover most of what';
say 'a DPath expression would:';
my %data = servers => [
    %( name => 'alpha', tags => <web prod> ),
    %( name => 'beta',  tags => <db staging> ),
    %( name => 'gamma', tags => <web staging> ),
];

say '  all server names        : ', %data<servers>.map(*<name>).join(', ');
say '  names tagged "web"      : ',
    %data<servers>.grep({ 'web' (elem) .<tags> }).map(*<name>).join(', ');
say '  deep, with a fallback   : ', (%data<servers>[9]<name> // '(none)');
say '';
say 'and for a genuine query language over nested data, the ecosystem has';
say 'JSON::Path and XML::XPath, both of which do the thing this name';
say 'suggests.';
```

```output
Raku`s own postcircumfix and Hash/Array methods cover most of what
a DPath expression would:
  all server names        : alpha, beta, gamma
  names tagged "web"      : alpha, gamma
  deep, with a fallback   : (none)

and for a genuine query language over nested data, the ecosystem has
JSON::Path and XML::XPath, both of which do the thing this name
suggests.
```

## Where the two engines differ

Nothing — there is not enough here to differ. The only observable difference
is that Rakudo's `^methods(:local)` includes its internal `POPULATE` and
Raku++'s does not, which is why the listing above filters it out.

```raku name="metadata"
use Data::DPath6;

say 'one thing about the distribution itself that is worth knowing:';
say 'it is not in the zef index. `rakupp test` resolves it from the REA';
say 'archive and notes that the index path carries no checksum, so TLS is';
say 'the only integrity check on the fetch.';
say '';
say 'its declared source URL uses the git:// scheme, which GitHub no';
say 'longer serves.';
say '';
say 'the version is 0.0.2 and the method is still `hello`.';
say '  ', Data::DPath6.hello;
```

```output
one thing about the distribution itself that is worth knowing:
it is not in the zef index. `rakupp test` resolves it from the REA
archive and notes that the index path carries no checksum, so TLS is
the only integrity check on the fetch.

its declared source URL uses the git:// scheme, which GitHub no
longer serves.

the version is 0.0.2 and the method is still `hello`.
  42
```
