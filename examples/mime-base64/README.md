# MIME::Base64 — the examples

Every example from [the MIME::Base64 page](https://raku.online/ecosystem/mime-base64/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install MIME::Base64   # or: zef install MIME::Base64
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.6.0 (dev build) and under Rakudo 2026.07, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | checked |
| [`02-bytes.raku`](02-bytes.raku) | Bytes | checked |
| [`03-unicode.raku`](03-unicode.raku) | Text, and what "text" means | checked |
| [`04-oneline.raku`](04-oneline.raku) | `:oneline`, and why the default has newlines in it | checked |
| [`05-basic-auth.raku`](05-basic-auth.raku) | The header everybody writes | checked |
