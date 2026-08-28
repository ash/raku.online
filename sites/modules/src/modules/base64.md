---
name: Base64
version: 0.1.0
auth: github:ugexe
kind: Distribution · data format
summary: Base64 in pure Raku with the two alphabets that matter — standard
  and URL-safe — from the author of zef, with no dependencies to drag in.
status: full
license: Artistic-2.0
suite: 2 files, green
tested: 2026-08-28
raku-land: https://raku.land/github:ugexe/Base64
---

## What it is for

Base64 is how binary rides in places that only accept text — JSON fields,
HTTP headers, URLs, `data:` URIs. This is `ugexe`'s implementation: two
subs, `encode-base64` and `decode-base64`, pure Raku, depending on
nothing — the property that made it the encoding layer under fourteen
other distributions, where a dependency of a dependency is exactly what
you do not want:

```raku name="encode-decode"
use Base64;

say encode-base64('Raku is fun!', :str);
say decode-base64('UmFrdSBpcyBmdW4h', :bin).decode;
```

```output
UmFrdSBpcyBmdW4h
Raku is fun!
```

The adverbs are doing quiet work there. Without `:str`, `encode-base64`
returns the encoded *characters* as a sequence — a design that lets you
stream them — so `:str` is the spelling for the common case of wanting one
string. On the way back, `:bin` makes `decode-base64` hand you a `Buf` of
the original bytes; `.decode` then turns bytes into text when the payload
*was* text, and stays un-called when it was an image.

## The URL-safe alphabet

Standard Base64 uses `+` and `/` — two characters with jobs of their own
inside URLs and filenames. RFC 4648's *URL-safe* variant swaps them for
`-` and `_`, and `:uri` selects it on both subs:

```raku name="url-safe"
use Base64;

my $bytes = Blob.new(251, 255, 190);
say encode-base64($bytes, :str);
say encode-base64($bytes, :str, :uri);
say decode-base64('-_--', :uri, :bin).list;
```

```output
+/++
-_--
(251 255 190)
```

Those three bytes are chosen to hit the difference: encode them one way
and you get `+/++`, the other way `-_--`. If you have ever seen a JWT —
three dot-separated blocks of exactly this alphabet — you have seen `:uri`
Base64 in the wild, and this is the sub pair that reads and writes it.

## Base64 or MIME::Base64?

The ecosystem has two Base64 distributions with a page here, and the
choice is simpler than it looks.
[MIME::Base64](/modules/mime-base64/) matches Perl's module of the same
name — it line-wraps its output at 76 columns for the email tradition that
named it, and speaks `Str`-in/`Str`-out by default. This one is
bytes-first, never wraps, and has the URL-safe alphabet built in. For a
`data:` URI, an HTTP `Authorization: Basic` header, or anything
JWT-shaped, this module's defaults are the right ones; for MIME mail
bodies, use the one named after the job.

## Where the two engines differ

Nothing on this page. Both alphabets, the sequence-vs-string return
shapes, and the byte-exact round trips answer identically under Raku++
and Rakudo.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install Base64`. This distribution is not in the
   zef index, so the installer resolved it from the REA archive; it
   depends on nothing.
3. **Test** — the distribution's own suite: 2 files, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

Nothing had to be fixed anywhere — an implementation built from `rotor`,
`Slip` and bit-shifts over blobs, running byte-identically on both
engines, is the sort of quiet conformance statement this site collects.
