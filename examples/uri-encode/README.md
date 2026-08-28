# URI::Encode — the examples

Every example from [the URI::Encode page](https://raku.online/modules/uri-encode/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install URI::Encode   # or: zef install URI::Encode
rakupp 01-two-questions.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-two-questions.raku`](01-two-questions.raku) | What it is for | checked |
| [`02-query-string.raku`](02-query-string.raku) | Building a query string | checked |
| [`03-decoding.raku`](03-decoding.raku) | Decoding, and the plus sign | checked |
