---
name: MIME::QuotedPrint
version: 1.0.0
auth: none stated
kind: Distribution · encoding
summary: Quoted-printable encoding and decoding — bytes outside printable
  ASCII become =XX escapes — with a byte pair, a text pair, and the RFC 2047
  header variant.
status: full
suite: 1 file, green
tested: 2026-09-15
license: CC0-1.0
depends: none beyond the core
raku-land: https://raku.land/?/MIME::QuotedPrint
source: git://github.com/retupmoca/p6-MIME-QuotedPrint.git
---

## What it is for

Quoted-printable is the transfer encoding mail uses when the body is mostly
ASCII with a few accented characters: it leaves the readable bytes alone and
escapes the rest as `=XX`, so the result stays roughly legible and survives
seven-bit transports.

This distribution encodes and decodes it, in both a byte-oriented and a
text-oriented flavour, plus the `Q` variant RFC 2047 uses inside mail headers.

## Encoding and decoding

```raku name="qp"
use MIME::QuotedPrint;

constant QP = MIME::QuotedPrint;

sub show(Str $s) { $s.subst("\r", '\r', :g).subst("\n", '\n', :g) }

for 'hello world', 'a=b', 'caf' ~ "\c[LATIN SMALL LETTER E WITH ACUTE]",
    "tab\there", 'trailing space ', '' -> $in {
    my $enc = QP.encode-str($in);
    my $dec = QP.decode-str($enc);
    say sprintf('in=%-22s enc=%-26s round-trip=%s',
        $in.raku, show($enc).raku, $dec eq $in ?? 'exact' !! 'DIFFERS');
}
```

```output
in="hello world"          enc="hello world"              round-trip=exact
in="a=b"                  enc="a=3Db"                    round-trip=exact
in="café"                 enc="caf=C3=A9"                round-trip=exact
in="tab\there"            enc="tab\there"                round-trip=exact
in="trailing space "      enc="trailing space =\\n"      round-trip=exact
in=""                     enc=""                         round-trip=exact
```

Nothing is exported — all four routines are methods on the class, callable on
the type object.

## Bytes

```raku name="bytes"
use MIME::QuotedPrint;

constant QP = MIME::QuotedPrint;

my $blob = Blob.new(0x00, 0x1F, 0x3D, 0x41, 0x7F, 0x80, 0xFF);
my $enc  = QP.encode($blob);
my $dec  = QP.decode($enc);

say 'input bytes  : ', $blob.list.map({ .fmt('%02X') }).join(' ');
say 'encoded      : ', $enc.raku;
say 'decoded bytes: ', $dec.list.map({ .fmt('%02X') }).join(' ');
say 'byte-exact   : ', $dec.list eqv $blob.list;
```

```output
input bytes  : 00 1F 3D 41 7F 80 FF
encoded      : "=00=1F=3DA=7F=80=FF"
decoded bytes: 00 1F 3D 41 7F 80 FF
byte-exact   : True
```

`encode`/`decode` take and give `Blob`/`Buf`; `encode-str`/`decode-str` do the
UTF-8 conversion for you.

## Mail-header mode

```raku name="header"
use MIME::QuotedPrint;

constant QP = MIME::QuotedPrint;

for 'a b c', 'under_score', 'x?y', 'caf' ~ "\c[LATIN SMALL LETTER E WITH ACUTE]" -> $in {
    my $enc = QP.encode-str($in, :mime-header);
    say sprintf('%-12s -> %-16s round-trip=%s',
        $in.raku, $enc.raku, QP.decode-str($enc, :mime-header) eq $in ?? 'exact' !! 'DIFFERS');
}
```

```output
"a b c"      -> "a_b_c"          round-trip=exact
"under_score" -> "under=5Fscore"  round-trip=exact
"x?y"        -> "x=3Fy"          round-trip=exact
"café"       -> "caf=C3=A9"      round-trip=exact
```

The `Q` encoding differs from the body encoding in three places: a space
becomes `_`, a literal underscore must be escaped, and `?` must be escaped
because it delimits the encoded-word. All three are handled.

## The one thing to know

The decoder cannot read standards-conformant quoted-printable.

RFC 2045's soft line break is `=` CR LF — which is what every mail agent on
earth emits. This decoder only understands `=` LF, and on the standard form it
tries to parse the `\r\n` as a hex pair and dies.

```raku name="crlf-trap"
use MIME::QuotedPrint;

constant QP = MIME::QuotedPrint;

my $mine = QP.encode-str('A' x 100);
say 'this encoder emits its soft break as : ', $mine.substr(74, 3).ords.List.raku,
    "   ('=' then LF)";
say 'and decodes its own output exactly   : ', QP.decode-str($mine) eq 'A' x 100;
say '';
my $rfc = $mine.subst("=\n", "=\r\n", :g);
say 'the RFC form is                      : ', $rfc.substr(74, 4).ords.List.raku,
    "   ('=' then CR then LF)";
my $out = try QP.decode-str($rfc);
say 'decoding it                          : ', $! ?? 'threw' !! 'ok';
say '';
say 'the fix is to normalise first:';
say '  ', QP.decode-str($rfc.subst("=\r\n", "=\n", :g)) eq 'A' x 100;
```

```output
this encoder emits its soft break as : (65, 61, 10)   ('=' then LF)
and decodes its own output exactly   : True

the RFC form is                      : (65, 61, 13, 10, 65)   ('=' then CR then LF)
decoding it                          : threw

the fix is to normalise first:
  True
```

The encoder and decoder are self-consistent, so a round trip inside this
module always passes — the incompatibility only surfaces against real mail,
which is the worst place for it to surface. Normalise `=\r\n` to `=\n` before
decoding anything from the wire.

## Where the two engines differ

Only in the exception type raised on that malformed input, which is a
distinction without a difference given that neither one is useful. Raku++
raises `X::Str::Numeric` from the hex conversion; Rakudo raises an
`X::TypeCheck` from initialising a `Buf` element with a `Failure`.

Two things that are the same on both and worth guarding. Malformed escapes are
**silently swallowed** rather than reported: `decode-str('=')` and
`decode-str('=Z')` both return the empty string, dropping the characters, while
`decode-str('=ZZ')` throws. So corrupt input decodes to short output with no
signal, inconsistently.

And a literal newline in the input is hard-escaped to `=0A` rather than
becoming a line break, so the encoder always produces a single logical line
whose only breaks are its own soft ones.
