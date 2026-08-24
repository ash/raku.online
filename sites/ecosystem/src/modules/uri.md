---
name: URI
version: 0.3.8
auth: zef:raku-community-modules
kind: Distribution · web
summary: RFC 3986 in a Raku grammar. Take a URI apart into scheme, host, path
  and query, put a new one together, and get the escaping right without thinking
  about it.
status: full
license: Artistic-2.0
suite: 14 files, green
tested: 2026-08-24
raku-land: https://raku.land/zef:raku-community-modules/URI
source: https://github.com/raku-community-modules/URI
---

## What it is for

You have a URL as a string and you need one piece of it — the host, the path,
one query parameter. Splitting on `/` and `?` works until it doesn't: a
password with an `@` in it, an IPv6 host in brackets, a query value containing
an encoded `&`. `URI` parses the actual grammar from RFC 3986 and hands you the
parts:

```raku name="tour"
use URI;

my $u = URI.new('https://raku.land/zef:timo/JSON::Fast?ver=0.20.1#docs');
say $u.scheme;
say $u.host;
say $u.path;
say $u.query;
say $u.fragment;
```

```output
https
raku.land
/zef%3Atimo/JSON%3A%3AFast
ver=0.20.1
docs
```

Note the path: the colons came back **percent-encoded**, because that is what
they are on the wire. The module gives you the URI as the URI actually is, not
as it looked when you typed it.

## The parts of an authority

Everything between the `//` and the path is the authority, and it has three
pieces of its own — userinfo, host, port — each available separately:

```raku name="authority"
use URI;

my $u = URI.new('https://user:pw@example.com:8443/a/b/c.html');
say $u.authority;
say $u.userinfo;
say $u.host;
say $u.port;
```

```output
user:pw@example.com:8443
user:pw
example.com
8443
```

When the URI does not spell out a port, `.port` gives the scheme's default —
that is `.default-port` doing the work, and it is why you can hand `.port`
straight to a socket:

```raku name="ports"
use URI;

say URI.new('http://example.com/').port;
say URI.new('https://example.com/').port;
say URI.new('http://example.com/').default-port;
```

```output
80
443
80
```

An IPv6 literal keeps its brackets, which is the right answer — the brackets
are part of the host production in the grammar, and stripping them would make
`host` ambiguous with a port:

```raku name="ipv6"
use URI;

my $u = URI.new('https://[2001:db8::1]:8080/p');
say $u.host;
say $u.port;
```

```output
[2001:db8::1]
8080
```

## The path, and its segments

`.segments` splits the path the way the RFC does — which means a leading empty
segment for an absolute path, and a trailing empty one when the path ends in a
slash. Both are information, not noise: they are how you tell `/a/b` from
`/a/b/`.

```raku name="segments"
use URI;

say URI.new('https://example.com/a/b/').segments.raku;
say URI.new('https://example.com/a/b').segments.raku;
say URI.new('https://example.com').path.Str.raku;
```

```output
("", "a", "b", "")
("", "a", "b")
""
```

## The query is not a Hash

A query string may repeat a key — `?tag=fast&tag=fun` is legal and means two
tags — so `.query` hands back a `URI::Query`, which indexes like a Hash but
answers with a **list** every time:

```raku name="query"
use URI;

my $u = URI.new('https://example.com/search?q=raku&page=2&tag=fast&tag=fun');
say $u.query;
say $u.query.^name;
say $u.query<q>;
say $u.query<page>;
say $u.query<tag>.join(',');
say $u.query.keys.sort.squish.join(' ');
```

```output
q=raku&page=2&tag=fast&tag=fun
URI::Query
(raku)
(2)
fast,fun
page q tag
```

`(raku)` rather than `raku` is the point of the class: one code path whether a
parameter appeared once or five times. `.keys` repeats a key once per
occurrence, hence the `.squish`.

Decoding happens on the way out, so a value that arrived percent-encoded is
readable by the time you see it:

```raku name="decoding"
use URI;

my $u = URI.new('https://example.com/a%20b/c?q=one%20two');
say $u.path;
say $u.query<q>;
```

```output
/a%20b/c
(one two)
```

## Building one

The accessors are also mutators. Assign a path or a query and stringify the
result — `.path-query` gives you the half a request line wants:

```raku name="build"
use URI;

my $u = URI.new('https://example.com/');
$u.path('/api/v2/things');
$u.query('page=2&per=50');
say ~$u;
say $u.path-query;
```

```output
https://example.com/api/v2/things?page=2&per=50
/api/v2/things?page=2&per=50
```

## Absolute, relative, and one method to avoid

`.is-absolute` and `.is-relative` answer the question a router asks:

```raku name="absolute"
use URI;

say URI.new('https://example.com/a').is-absolute;
say URI.new('/just/a/path').is-absolute;
say URI.new('/just/a/path').is-relative;
```

```output
True
False
True
```

`rel2abs` resolves a relative reference against a base, and it takes the base
as a **URI**, not a string — `URI.new($relative).rel2abs($base)`, not
`$base.rel2abs($relative)`:

```raku name="rel2abs"
use URI;

my $base = URI.new('https://example.com/docs/guide/index.html');
say URI.new('/top.html').rel2abs($base);
say URI.new('https://other.example/x').rel2abs($base);
```

```output
https://example.com/top.html
https://other.example/x
```

> Keep to the absolute and already-absolute cases. A **dot-segment** reference —
> `URI.new('../api/v2.html').rel2abs($base)` — does not walk the path: it
> concatenates, and returns
> `https://example.comhttps://example.com/docs/guide/index.html/../api/v2.html`.
> That is the module's own behaviour and it is **identical under both engines**,
> so it is a bug to route around, not an engine difference. Resolve dot segments
> yourself, or keep your references rooted.

## Where the two engines differ

One method, and it is one the module already asks you not to call.

**`.query-form` is deprecated, and under Raku++ it also answers differently.**
Rakudo's `URI.query-form` returns the `URI::Query` object; Raku++ returns a
plain `Array`, so `.keys` gives `0,1,2` instead of the parameter names and a
`<x y>` slice comes back `Any`. The cause is a dispatch difference the module
happens to expose: it declares both `multi method query-form(URI:D: |c)` and a
later `multi method query-form()`, and for a no-argument call Rakudo picks the
empty signature while Raku++ picks the capture. Reduced to its bones, the whole
divergence is this:

```raku
class C {
    proto method m(|) { * }
    multi method m(C:D: |c) { 'capture' }
    multi method m()        { 'empty'   }
}
say C.new.m;      # Rakudo: empty      Raku++: capture
```

Both engines deprecate `.query-form` in favour of `.query`, which behaves
identically on both — every query example on this page uses it. Nothing else on
this page differs.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install URI`, no dependencies to pull.
3. **Test** — the distribution's own suite: 14 files, 222 assertions, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

The suite went from 88 of 222 to all 222 over a single day, on twenty general
interpreter fixes and not one line of URI. The ones with the widest blast
radius were not about URIs at all. Type conformance had *two* implementations —
`~~` knew the whole story while parameter dispatch used a laxer test that
returned a blanket true for any type object, so a multi could be dispatched
away on the engine's ignorance. A typed attribute assigned `Nil` reset to bare
`Any` instead of to its declared type, so the next `$!authority .= new(…)` had
nothing to call `new` on. A coercion parameter, `Str() $x`, scored as high as
an exact nominal type, so `multi method authority(Str() $a)` tied with `multi
method authority(Nil)` and won on declaration order — meaning `.authority(Nil)`
could never clear the authority. And `%h<k> = 1, 2` stored only `1`: every
subscript assignment takes the whole comma list, which was wrong for ordinary
hashes and arrays too, and only showed up here because `URI::Query` writes
`$q<foo> = '5', '6'`.
