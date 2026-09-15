# TinyFloats — the examples

Every example from [the TinyFloats page](https://raku.online/modules/tinyfloats/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install TinyFloats   # or: zef install TinyFloats
rakupp 01-convert.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-convert.raku`](01-convert.raku) | Converting | checked |
| [`02-formats.raku`](02-formats.raku) | The four formats side by side | checked |
| [`03-boundaries.raku`](03-boundaries.raku) | Boundaries | checked |
| [`04-range.raku`](04-range.raku) | Where the two engines differ | checked |
