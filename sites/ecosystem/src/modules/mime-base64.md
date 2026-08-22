---
name: MIME::Base64
version: 1.2.5
auth: zef:raku-community-modules
kind: Distribution · encoding
summary: Bytes to ASCII and back — the encoding behind Basic auth, data URIs,
  and every place binary has to travel through a text-only channel.
status: full
license: Artistic-2.0
suite: 4 files, green
tested: 2026-08-22
raku-land: https://raku.land/zef:raku-community-modules/MIME::Base64
source: https://github.com/raku-community-modules/MIME-Base64
---

## What it is for

Something in the middle of your program only carries text — an HTTP header, a
JSON string, an email body, a `data:` URL — and what you have is bytes. Base64
is the standard way through, and this module is four methods on one class:

```raku name="tour"
use MIME::Base64;

say MIME::Base64.encode-str('Raku++ makes JSON go');
say MIME::Base64.decode-str('UmFrdSsrIG1ha2VzIEpTT04gZ28=');
```

```output
UmFrdSsrIG1ha2VzIEpTT04gZ28=
Raku++ makes JSON go
```

The pairing is worth naming once, because getting it backwards is the usual
mistake: `encode`/`decode` work on **`Buf`**, and `encode-str`/`decode-str`
work on **`Str`**, doing the UTF-8 step for you.

## Bytes

`encode` takes a buffer and gives you a string; `decode` gives the buffer back,
byte for byte — including the bytes that are not printable text:

```raku name="bytes"
use MIME::Base64;

my $blob = Buf.new(0x00, 0xff, 0x10, 0x80, 0x7f);
my $b64  = MIME::Base64.encode($blob);
say $b64;
say MIME::Base64.decode($b64).list.fmt('%02x', ' ');
say MIME::Base64.decode($b64) eqv $blob;
```

```output
AP8QgH8=
00 ff 10 80 7f
True
```

The `=` on the end is padding: Base64 works in groups of three bytes, and five
bytes is one short of two full groups.

## Text, and what "text" means

`encode-str` encodes the string's **UTF-8 bytes**, so anything you can write in
Raku survives the trip — accents, dashes, scripts that need three bytes a
character:

```raku name="unicode"
use MIME::Base64;

my $text = "naïve café — 日本語";
my $b64  = MIME::Base64.encode-str($text, :oneline);
say $b64;
say MIME::Base64.decode-str($b64);
say MIME::Base64.decode-str($b64) eq $text;
```

```output
bmHDr3ZlIGNhZsOpIOKAlCDml6XmnKzoqp4=
naïve café — 日本語
True
```

## `:oneline`, and why the default has newlines in it

MIME wraps encoded data at 76 characters, because that is what mail bodies
wanted, and this module keeps that default. Anywhere else — an HTTP header, a
JSON field, a URL — the line breaks are wrong, and `:oneline` removes them:

```raku name="oneline"
use MIME::Base64;

my $long = Buf.new(0..99);
say MIME::Base64.encode($long).lines.elems;
say MIME::Base64.encode($long, :oneline).lines.elems;
say MIME::Base64.encode($long).lines[0].chars;
```

```output
2
1
76
```

If you are putting the result into a header, pass `:oneline`. It is the single
most common bug with this module, and it does not show up until the input is
long enough to wrap.

## The header everybody writes

Basic authentication is `user:password`, Base64'd, after the word `Basic` —
which makes it the shortest useful example of the whole module:

```raku name="basic-auth"
use MIME::Base64;

my ($user, $pass) = 'ash', 's3cr3t';
my $header = 'Basic ' ~ MIME::Base64.encode-str("$user:$pass", :oneline);
say $header;
say MIME::Base64.decode-str($header.substr(6)).split(':').head;
```

```output
Basic YXNoOnMzY3IzdA==
ash
```

That round trip is also the reminder that Base64 is **not** encryption. It is
an encoding: anyone holding the header can read the password back with the line
above. Basic auth is safe only inside TLS.

## Where the two engines differ

Nothing on this page. Every example prints the same bytes under Raku++ and
under Rakudo, twice on each.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install MIME::Base64`, no dependencies to pull.
3. **Test** — the distribution's own suite: 4 files, green.
4. **Run** — every example on this page, twice under each engine, as the site
   is built.

This was one of the first modules the campaign fixed, and it took two general
faults with nothing to do with Base64. A `Buf` did not iterate its **bytes** in
a `for` loop — it arrived as a single item, so the module's
`for $data -> $b1, $b2?, $b3?` read the whole buffer as one value and the
encoder emitted `AA==` for every input. And an allomorph — the `IntStr` that
`<8>` produces — would not bind to a native `str` parameter or push into a
`str @` array through its string side, which is how the module carries its
alphabet. Fixing the first also fixed reading a buffer three bytes at a time
anywhere else in the language.
