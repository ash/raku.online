# String::Utils — the examples

Every example from [the String::Utils page](https://raku.online/modules/string-utils/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install String::Utils   # or: zef install String::Utils
rakupp 01-strutils.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-strutils.raku`](01-strutils.raku) | Cutting a string at a marker | checked |
