# Cro::Core — the examples

Every example from [the Cro::Core page](https://raku.online/modules/cro-core/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Cro::Core   # or: zef install Cro::Core
rakupp 01-uri.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-uri.raku`](01-uri.raku) | Taking a URI apart | checked |
| [`02-relative.raku`](02-relative.raku) | Resolving a relative reference | checked |
| [`03-mediatype.raku`](03-mediatype.raku) | Media types, including the suffix | checked |
