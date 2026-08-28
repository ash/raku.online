---
name: URI::Encode
version: 1.0
auth: zef:raku-community-modules
kind: Distribution · web
summary: Percent-encoding and decoding per RFC 3986 — with the distinction
  that matters kept intact, between escaping a whole URL and escaping one
  value going into it.
status: full
license: BSD-2-Clause-FreeBSD
suite: 2 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:raku-community-modules/URI::Encode
source: https://github.com/raku-community-modules/URI-Encode
---

## What it is for

Somewhere a string of yours is about to travel inside a URL — a search
term, a filename, a redirect target — and it contains a space, an
ampersand, or an `é`. Percent-encoding is the fix, and the entire skill is
knowing **which of two questions you are asking**. This module gives each
question its own sub, the same split JavaScript makes between `encodeURI`
and `encodeURIComponent`:

```raku name="two-questions"
use URI::Encode;

my $url = 'https://example.com/search?q=café au lait&lang=fr';
say uri_encode($url);
say uri_encode_component('café au lait & more');
```

```output
https://example.com/search?q=caf%C3%A9%20au%20lait&lang=fr
caf%C3%A9%20au%20lait%20%26%20more
```

`uri_encode` treats the string as *already being a URL*: it escapes what
cannot appear at all (the space, the `é` as UTF-8 bytes) but leaves RFC
3986's reserved characters — `: / ? # & =` and friends — alone, because in
a URL they are structure. `uri_encode_component` treats the string as *one
value*: everything but the unreserved characters is escaped, so the `&`
inside the value can no longer be mistaken for a parameter separator.
Passing a whole URL to the component form, or a raw value to the URL form,
is the classic bug this module's two names exist to prevent.

## Building a query string

The component form is the one you want in the everyday job of putting
values into a query. Ampersands in the data survive, spaces become `%20`,
and the URL's own structure stays yours:

```raku name="query-string"
use URI::Encode;

my @params = department => 'R&D', q => 'raku modules', page => 2;
my $query = @params.map({ .key ~ '=' ~ uri_encode_component(.value.Str) }).join('&');
say 'https://example.com/search?' ~ $query;
```

```output
https://example.com/search?department=R%26D&q=raku%20modules&page=2
```

An array of pairs, not a hash — a hash would shuffle the parameter order
from run to run, and while servers should not care, cache keys, signed
URLs and test assertions all do.

## Decoding, and the plus sign

`uri_decode` reverses the percent-escapes, decoding the bytes as UTF-8.
One thing it deliberately does **not** do: turn `+` into a space. That
rule belongs to HTML form encoding (`application/x-www-form-urlencoded`),
not to RFC 3986 — a `+` in a path or query is just a plus. If you are
parsing form bodies, split on `&`, translate `+` to space, *then* decode:

```raku name="decoding"
use URI::Encode;

say uri_decode('caf%C3%A9%20au%20lait');
say uri_decode('a+b%20c');
say uri_decode_component('100%25%20%2B%2020%25');
```

```output
café au lait
a+b c
100% + 20%
```

Round-tripping holds by construction: `uri_decode(uri_encode_component($s))`
gives back `$s` for any string, since the component form escapes everything
ambiguous and the decoder only touches escapes.

## Where the two engines differ

Nothing on this page. Encoding, decoding, and the UTF-8 byte handling for
non-ASCII text answer identically under Raku++ and Rakudo.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install URI::Encode`; it depends on nothing
   outside the core.
3. **Test** — the distribution's own suite: 2 files, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

Nothing had to be fixed anywhere. Worth knowing: the heavier
[URI](/modules/uri/) distribution — full URL parsing rather than just
escaping — carries its own `uri-escape`/`uri-unescape` subs in a
`URI::Escape` module; this one is the standalone version of that job, at
twenty-four dependent distributions to URI's thirty-four.
