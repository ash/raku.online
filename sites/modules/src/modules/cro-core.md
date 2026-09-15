---
name: Cro::Core
version: 0.8.10
auth: zef:cro
kind: Distribution · web
summary: The pieces every Cro library is built from — a URI and IRI parser that
  implements RFC 3986 resolution, a media-type parser that splits the structured
  suffix, and the pipeline composer the HTTP and WebSocket libraries plug into.
status: full
suite: 9 files, green
tested: 2026-09-16
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:cro/Cro::Core
source: https://github.com/croservices/cro-core.git
---

## What it is for

Cro is a set of libraries for writing services, and this distribution is the
layer underneath all of them: twenty-three units that between them define what
a message is, what a connector is, how components are composed into a pipeline,
and — the part that is useful entirely on its own — how to parse a URI, an IRI
and a media type.

You do not need to be writing a Cro service to want the last group. `Cro::Uri`
is a complete RFC 3986 implementation with reference resolution, which the core
language does not ship, and `Cro::MediaType` knows about structured suffixes,
which is the difference between recognising `application/vnd.api+json` as JSON
and not recognising it at all.

## Taking a URI apart

```raku name="uri"
use Cro::Uri;

my $u = Cro::Uri.parse('https://ash:s3cret@example.com:8443/a/b%20c/d?q=1&r=2#frag');

for <scheme userinfo user password host port authority path query fragment> -> $part {
    my $v = $u."$part"();
    say sprintf('%-10s %s', $part, $v.defined ?? $v.Str !! '(Nil)');
}
say '';
say 'path          : ', $u.path;
say 'path-segments : ', $u.path-segments.join(' | ');
say 'round-trip    : ', $u.Str;
```

```output
scheme     https
userinfo   ash:s3cret
user       ash
password   s3cret
host       example.com
port       8443
authority  ash:s3cret@example.com:8443
path       /a/b%20c/d
query      q=1&r=2
fragment   frag

path          : /a/b%20c/d
path-segments : a | b c | d
round-trip    : https://ash:s3cret@example.com:8443/a/b%20c/d?q=1&r=2#frag
```

Two of those rows are worth pausing on. `port` answered `8443` without being
asked to coerce, because the parser stores it as an `Int`. And `path` keeps the
percent-encoding while `path-segments` does not: the segment list is the decoded
form, so `b%20c` arrives as `b c`. That is the right split — a path is compared
and rebuilt in its encoded form, while a segment is what you match against —
but it does mean the two views disagree by design, and joining `path-segments`
back together does not reproduce `path`.

## Resolving a relative reference

`.add` is RFC 3986 section 5.2, the algorithm a browser applies when it sees
`href="../x"` on a page. The specification ships a table of worked examples in
section 5.4, and the module gets all of them right:

```raku name="relative"
use Cro::Uri;

my $base = Cro::Uri.parse('http://a/b/c/d;p?q');

# The reference-resolution examples from RFC 3986 section 5.4.
for <g ./g g/ /g //g ?y g?y #s g#s . ./ .. ../ ../.. ../../g> -> $ref {
    say sprintf('%-8s -> %s', $ref, $base.add($ref).Str);
}
```

```output
g        -> http://a/b/c/g
./g      -> http://a/b/c/g
g/       -> http://a/b/c/g/
/g       -> http://a/g
//g      -> http://g
?y       -> http://a/b/c/d;p?y
g?y      -> http://a/b/c/g?y
#s       -> http://a/b/c/d;p?q#s
g#s      -> http://a/b/c/g#s
.        -> http://a/b/c/
./       -> http://a/b/c/
..       -> http://a/b/
../      -> http://a/b/
../..    -> http://a/
../../g  -> http://a/g
```

`//g` losing the path entirely is correct and surprising the first time: a
reference beginning with `//` replaces the whole authority, so the base's host
`a` is discarded along with `/b/c/d;p`. The dot segments are the other half of
the algorithm — `..` is resolved textually against the base path, never against
a filesystem, so it cannot escape past the root.

## Media types, including the suffix

```raku name="mediatype"
use Cro::MediaType;

for 'text/plain; charset=UTF-8',
    'application/vnd.api+json',
    'image/svg+xml',
    'application/x-www-form-urlencoded' -> $s {
    my $m = Cro::MediaType.parse($s);
    say $s;
    say '   type            ', $m.type;
    say '   tree            ', $m.tree       || '(none)';
    say '   subtype-name    ', $m.subtype-name;
    say '   suffix          ', $m.suffix     || '(none)';
    say '   subtype         ', $m.subtype;
    say '   type-and-subtype ', $m.type-and-subtype;
    say '   parameters      ', $m.parameters.map({ .key ~ '=' ~ .value }).join(', ') || '(none)';
}
```

```output
text/plain; charset=UTF-8
   type            text
   tree            (none)
   subtype-name    plain
   suffix          (none)
   subtype         plain
   type-and-subtype text/plain
   parameters      charset=UTF-8
application/vnd.api+json
   type            application
   tree            vnd
   subtype-name    api
   suffix          json
   subtype         vnd.api+json
   type-and-subtype application/vnd.api+json
   parameters      (none)
image/svg+xml
   type            image
   tree            (none)
   subtype-name    svg
   suffix          xml
   subtype         svg+xml
   type-and-subtype image/svg+xml
   parameters      (none)
application/x-www-form-urlencoded
   type            application
   tree            (none)
   subtype-name    x-www-form-urlencoded
   suffix          (none)
   subtype         x-www-form-urlencoded
   type-and-subtype application/x-www-form-urlencoded
   parameters      (none)
```

The four-way split is what the page is here for. `type-and-subtype` is what you
would match on to route a request. `subtype` is the whole subtype as written.
`tree` is the registration branch — `vnd` for vendor-registered types, empty for
standards-tree ones — and `suffix` is the `+json` or `+xml` tail that says what
the format actually *is*.

So `application/vnd.api+json` is a vendor type whose encoding is JSON, and a
body parser that checks `.suffix eq 'json'` handles it, along with every other
`+json` type that will ever be registered, without a list. Checking
`type-and-subtype eq 'application/json'` handles none of them.

`tree` answers the empty string rather than `Nil` when there is no tree, so test
it with `||` or `.chars`, not `//` — `.defined` is always `True`.

## Where the two engines differ

Nowhere. Every URI part, all fifteen RFC 3986 resolution cases, and all four
media types produced identical output on Raku++ and Rakudo.

The distribution's own suite is nine files and passes whole on both. That is
worth saying explicitly because most of Cro is asynchronous and this layer is
where the asynchrony is *defined* — `Cro::Connector`, `Cro::Transform` and
`Cro.compose` are roles built on `Supply` and `Promise` — but the parsers
themselves are ordinary synchronous code, and it is the parsers that most
programs reaching for this distribution actually want.
