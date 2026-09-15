# Data::RandomKeep — the examples

Every example from [the Data::RandomKeep page](https://raku.online/modules/data-randomkeep/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Data::RandomKeep   # or: zef install Data::RandomKeep
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Sampling | checked |
| [`02-uniform.raku`](02-uniform.raku) | Uniformity | checked |
| [`03-sorted.raku`](03-sorted.raku) | The one thing to know | checked |
| [`04-constructor.raku`](04-constructor.raku) | The constructor takes a positional | checked |
| [`05-reservoir.raku`](05-reservoir.raku) | Where the two engines differ | checked |
