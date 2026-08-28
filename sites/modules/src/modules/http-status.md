---
name: HTTP::Status
version: 0.0.5
auth: zef:lizmat
kind: Distribution · web
summary: Every registered HTTP status code as an object that knows its
  title, its class, its RFC and where it came from — plus the one-line
  predicates for "is this an error?".
status: full
suite: 3 files, green
tested: 2026-08-28
raku-land: https://raku.land/zef:lizmat/HTTP::Status
source: https://github.com/lizmat/HTTP-Status
---

## What it is for

Somewhere in every HTTP-touching program a bare `404` needs to become
words — in a log line, an error page, a metrics label. This module is the
registry as data: call the class with a code and you get an object
carrying everything the IANA list (and the well-known extensions beyond
it) says about that code:

```raku name="lookup"
use HTTP::Status;

my $s = HTTP::Status(418);
say $s.code, ' ', $s.title;
say $s.type;
say "and 404 reads as: {HTTP::Status(404)}";
say HTTP::Status(999) // 'unknown code';
```

```output
418 I'm a teapot
Client Error
and 404 reads as: Not Found
unknown code
```

The object stringifies to its title, so it drops straight into
interpolation, and an unregistered code gives you an undefined value
rather than an exception — `//` your fallback in, as the last line does.
Note that `.type` names the hundred-class in words: Informational,
Success, Redirection, Client Error, Server Error.

## The predicates, and a log line

For branching you rarely want the object at all — you want one boolean.
Six exported subs test a bare code without constructing anything:
`is-info`, `is-success`, `is-redirect`, `is-error`, and the pair that
splits errors into whose fault they are:

```raku name="predicates"
use HTTP::Status;

say is-client-error(404), ' ', is-server-error(404);

for 301, 404, 503 -> $code {
    my $st = HTTP::Status($code);
    say $code ~ ' ' ~ $st ~ ' — ' ~ $st.type;
}
```

```output
True False
301 Moved Permanently — Redirection
404 Not Found — Client Error
503 Service Unavailable — Server Error
```

`is-client-error(404)`/`is-server-error(503)` is the pair to reach for in
retry logic — a 4xx will fail again exactly the same way, a 5xx might
not, and that one distinction is most of what "handle errors properly"
means against an HTTP API.

## Deeper than the title

Each object also knows *why it exists*: `.RFC` names the defining
document, `.since` the protocol version that introduced it, and
`.origin` who registered it — which is where the registry gets
interesting, because it includes the codes you meet in the wild that are
not IANA's at all, from Cloudflare's 5xx family to nginx's internals:

```raku name="provenance"
use HTTP::Status;

my $s = HTTP::Status(451);
say $s.title;
say 'RFC ', $s.RFC;

say HTTP::Status(525).title;
say HTTP::Status(525).origin;
```

```output
Unavailable For Legal Reasons
RFC 7725
SSL Handshake Failed
Cloudflare
```

There is also `.summary` — a sentence or three of prose per code, enough
to power a status reference page by itself — and the class-level
`HTTP::Status.pairs` hands you the whole registry at once. Code that
predates this API keeps working: the legacy
`get_http_status_msg(503)` sub is still exported and answers
`Service Unavailable`.

## Where the two engines differ

The module's answers are identical on both engines. One engine-level
caution its objects happen to expose: formatting an object with
`printf`/`sprintf` `%s` currently prints Raku++'s default representation
(`HTTP::Status<…id…>`) instead of calling the class's own `Str`, where
Rakudo prints the title. Interpolation, `~` concatenation and `say` all
stringify correctly on both engines — so write `"$st"` rather than
`sprintf '%s', $st` until that lands, on this or any class with a custom
`Str`.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install HTTP::Status`; it depends on nothing
   outside the core.
3. **Test** — the distribution's own suite: 3 files, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

A detail for connoisseurs: the registry loads through a `sink` method —
each `HTTP::Status.new: 404, …` at module load time registers itself by
being discarded, so the whole table is built by statements that appear to
do nothing. That idiom working is a small conformance statement about
sink context on both engines.
