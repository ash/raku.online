# Noise::Simplex — the examples

Every example from [the Noise::Simplex page](https://raku.online/modules/noise-simplex/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Noise::Simplex   # or: zef install Noise::Simplex
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Sampling a field | checked |
| [`02-reproducible.raku`](02-reproducible.raku) | Sampling a field | checked |
| [`03-tiling.raku`](03-tiling.raku) | The one thing to know | checked |
| [`04-seed.raku`](04-seed.raku) | The seed is taken modulo 2^64 | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
