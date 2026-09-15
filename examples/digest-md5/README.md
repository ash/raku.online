# Digest::MD5 — the examples

Every example from [the Digest::MD5 page](https://raku.online/modules/digest-md5/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Digest::MD5   # or: zef install Digest::MD5
rakupp 01-md5.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-md5.raku`](01-md5.raku) | One sub | checked |
| [`02-normalisation.raku`](02-normalisation.raku) | The one thing to know | checked |
