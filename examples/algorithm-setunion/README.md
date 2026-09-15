# Algorithm::SetUnion — the examples

Every example from [the Algorithm::SetUnion page](https://raku.online/modules/algorithm-setunion/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Algorithm::SetUnion   # or: zef install Algorithm::SetUnion
rakupp 01-union.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-union.raku`](01-union.raku) | Unioning and finding | checked |
| [`02-components.raku`](02-components.raku) | Reading the components out | checked |
| [`03-compression.raku`](03-compression.raku) | Path compression | checked |
| [`04-root-trap.raku`](04-root-trap.raku) | The one thing to know | checked |
