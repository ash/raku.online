# MIME::QuotedPrint — the examples

Every example from [the MIME::QuotedPrint page](https://raku.online/modules/mime-quotedprint/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install MIME::QuotedPrint   # or: zef install MIME::QuotedPrint
rakupp 01-qp.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-qp.raku`](01-qp.raku) | Encoding and decoding | checked |
| [`02-bytes.raku`](02-bytes.raku) | Bytes | checked |
| [`03-header.raku`](03-header.raku) | Mail-header mode | checked |
| [`04-crlf-trap.raku`](04-crlf-trap.raku) | The one thing to know | checked |
