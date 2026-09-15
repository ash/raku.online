---
name: Image::Markup::Utilities
version: 0.1.2
auth: zef:antononcube
kind: Distribution · images
summary: Turn an image file into a base64 data URI and wrap it in Markdown or
  HTML, so images can be embedded inline in notebooks and documents.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: HTTP::Tiny, MIME::Base64
raku-land: https://raku.land/zef:antononcube/Image::Markup::Utilities
source: https://github.com/antononcube/Raku-Image-Markup-Utilities
---

## What it is for

A notebook cell, a Markdown report or a self-contained HTML page cannot refer
to an image by path — the file has to travel with the document. The answer is
a `data:` URI: the bytes base64-encoded and inlined.

This distribution builds those, and wraps them in the markup the surrounding
document wants.

## Encoding an image

```raku name="encode"
use Image::Markup::Utilities;

my $dir = $*TMPDIR.add("img-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }

# a real 1x1 PNG, written from literal bytes
my $png = $dir.add('dot.png');
$png.spurt: Buf.new(
    0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,
    0x49,0x48,0x44,0x52,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,
    0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,0x89,0x00,0x00,0x00,
    0x0A,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
    0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,
    0x45,0x4E,0x44,0xAE,0x42,0x60,0x82);

say 'fixture bytes : ', $png.s;
say '';
my $enc = image-encode($png.absolute, :type<png>);
say 'image-encode returns a ', $enc.^name, ' of ', $enc.chars, ' chars';
say '  it starts : ', $enc.substr(0, 40);
```

```output
fixture bytes : 67

image-encode returns a Str of 114 chars
  it starts : data:image/png;base64,iVBORw0KGgoAAAANSU
```

## Wrapping it

```raku name="wrap"
use Image::Markup::Utilities;

my $dir = $*TMPDIR.add("img2-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }
my $png = $dir.add('dot.png');
$png.spurt: Buf.new(
    0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,
    0x49,0x48,0x44,0x52,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,
    0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,0x89,0x00,0x00,0x00,
    0x0A,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
    0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,
    0x45,0x4E,0x44,0xAE,0x42,0x60,0x82);

for 'md-image', 'html-image', 'base64' -> $f {
    my $r = image-import($png.absolute, :format($f));
    say sprintf('%-12s %3d chars, starts %s', $f, $r.chars, $r.substr(0, 28).raku);
}
```

```output
md-image     120 chars, starts "![](data:image/jpeg;base64,i"
html-image    92 chars, starts "iVBORw0KGgoAAAANSUhEUgAAAAEA"
base64       115 chars, starts "data:image/jpeg;base64,iVBOR"
```

Two of those names do not mean what they say. `:format<html-image>` returns
**bare base64 with no tag at all**, and `:format<base64>` returns a full
`data:` URI. The two are effectively swapped relative to what they produce.

## The one thing to know

The MIME type in the data URI is a caller-supplied label that is never checked
against the file.

```raku name="type-trap"
use Image::Markup::Utilities;

my $dir = $*TMPDIR.add("img3-{$*PID}");
$dir.mkdir;
LEAVE { .unlink for $dir.dir; $dir.rmdir }
my $png = $dir.add('dot.png');
$png.spurt: Buf.new(
    0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,
    0x49,0x48,0x44,0x52,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,
    0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,0x89,0x00,0x00,0x00,
    0x0A,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
    0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,
    0x45,0x4E,0x44,0xAE,0x42,0x60,0x82);

say 'the file is an unambiguous PNG — magic bytes 89 50 4E 47:';
say '  first four bytes : ', $png.slurp(:bin).subbuf(0, 4).list.map({ .fmt('%02X') }).join(' ');
say '';
for '(no :type)', '', ':type<png>', 'png', ':type<gif>', 'gif', ':type<banana>', 'banana' -> $label, $t {
    my $e = $t ?? image-encode($png.absolute, :type($t)) !! image-encode($png.absolute);
    say sprintf('  %-14s -> %s', $label, $e.substr(0, 27));
}
say '';
say 'and image-import has no :type parameter at all,';
say 'so every image it embeds is announced as JPEG.';
```

```output
the file is an unambiguous PNG — magic bytes 89 50 4E 47:
  first four bytes : 89 50 4E 47

  (no :type)     -> data:image/jpeg;base64,iVBO
  :type<png>     -> data:image/png;base64,iVBOR
  :type<gif>     -> data:image/gif;base64,iVBOR
  :type<banana>  -> data:image/banana;base64,iV

and image-import has no :type parameter at all,
so every image it embeds is announced as JPEG.
```

The default label is `jpeg` regardless of the file, and `:type<banana>`
produces `data:image/banana;base64,…` without complaint. A browser that
believes the label will refuse to render the image; one that sniffs the bytes
will work, and you will not find out which until it matters.

Pass the right `:type` every time, and do not use `image-import` for anything
but JPEG.

## Where the two engines differ

Only on a missing input file, where both return `Nil` with no exception and
Rakudo additionally warns `Use of Nil.substr coerced to empty string`. Check
`.e` yourself before calling.

One thing to know before you point this at a path: the distribution depends on
`HTTP::Tiny` because `$spec` can be a **URL**. Every call is therefore a
potential network fetch, and a path that happens to look like one will be
fetched rather than read.
