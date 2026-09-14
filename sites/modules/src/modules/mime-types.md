---
name: MIME::Types
version: 0.3
auth: zef:raku-community-modules
kind: Distribution · web
summary: The table from a file extension to a media type and back —
  `html` to `text/html`, `text/html` to its three extensions — as an object
  built from the list Apache ships, with nothing computed at all.
status: full
suite: 1 file, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/zef:raku-community-modules/MIME::Types
source: https://github.com/raku-community-modules/MIME-Types
---

## What it is for

A web server has to say `Content-Type: image/png` when it serves
`logo.png`, and the only thing it has to go on is the extension. The
mapping is a long, dull, well-known list — the `mime.types` file that comes
with Apache — and this distribution is that list parsed once into two
hashes, with a method for each direction. Six distributions depend on it,
every one of them something that serves files.

## Both directions

```raku name="lookup"
use MIME::Types;

my $m = MIME::Types.new;
say $m.type('html'), ' ', $m.type('png'), ' ', $m.type('json');
say $m.type('nope').raku;
say $m.extensions('text/html').sort.join(',');
say $m.types.elems > 500, ' ', $m.exts.elems > 500;
```

```output
text/html image/png application/json
Nil
htm,html,shtml
True True
```

`type` takes an extension without its dot and answers a string, or `Nil`
for one it has never heard of — which is the value to test for before
falling back to `application/octet-stream`. `extensions` goes the other
way and answers a list, since one type has several spellings. `types` and
`exts` are the whole tables, for the program that wants to build a
different index.

## The one thing to know

It is a lookup by extension and nothing more. The module does not open the
file, does not read magic bytes, and does not know that `notes.txt`
containing JSON is JSON; it maps the string after the last dot. That is the
right tool for serving a directory of files people named sensibly, and the
wrong one for an upload, where the name is whatever the client chose to
send. For uploads, sniff the bytes (`file --mime-type`, or the first few
bytes against the signatures you accept) and use this table only to choose
a name on the way out.
