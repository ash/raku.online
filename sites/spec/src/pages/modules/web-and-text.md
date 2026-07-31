---
title: Web building blocks — URI, XML, Base64, HTTP::Status
slug: web-and-text
status: full
browser: false
browser-why: needs installed module distributions
rakulib: battery
order: 30
summary: URI parsing and encoding, XML documents, Base64 in two flavours, and HTTP status texts — verified under Raku++.
---

The small modules every web-facing program leans on. Verified under Raku++ and
Rakudo on the same pinned sources.

## URI

Parse a URI into its parts.

```raku
use URI;
my $u = URI.new('https://raku.online/spec/modules/working/?q=json#top');
say $u.scheme;
say $u.host;
say $u.path;
say $u.query;
say $u.frag;
```
```output
https
raku.online
/spec/modules/working/
q=json
top
```

## URI::Encode

Percent-encoding for URLs — the component form encodes everything that isn't
safe inside a query value, and `uri_decode` turns the escapes back into text.

```raku
use URI::Encode;
say uri_encode_component('a раку & b');
say uri_decode('a%20%D1%80%D0%B0%D0%BA%D1%83%20%26%20b');
```
```output
a%20%D1%80%D0%B0%D0%BA%D1%83%20%26%20b
a раку & b
```

## XML

A full XML parser and document model — attributes, nested elements, and
stringification all round-trip.

```raku
use XML;

my $doc = from-xml('<library><book id="7" lang="raku">Grammars</book></library>');
my $book = $doc.root.elements(:TAG<book>)[0];
say $book.attribs<id>;
say $book.attribs<lang>;
say $book.nodes[0];
say $doc.root.elements.elems;
```
```output
7
raku
Grammars
1
```

## MIME::Base64 and Base64

Two takes on the same encoding: MIME::Base64 is class-shaped, Base64 exports
subs. Both round-trip cleanly.

```raku
use MIME::Base64;
my $enc = MIME::Base64.encode-str('Raku++ runs modules');
say $enc;
say MIME::Base64.decode-str($enc);
```
```output
UmFrdSsrIHJ1bnMgbW9kdWxlcw==
Raku++ runs modules
```

```raku
use Base64;
say encode-base64('hi', :str);
say decode-base64('aGk=', :bin).decode;
```
```output
aGk=
hi
```

## HTTP::Status

Status code to reason phrase — handy for building responses by hand.

```raku
use HTTP::Status;
say get_http_status_msg(200);
say get_http_status_msg(404);
say get_http_status_msg(418);
```
```output
OK
Not Found
I'm a teapot
```
