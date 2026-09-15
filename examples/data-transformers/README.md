# Data::Transformers — the examples

Every example from [the Data::Transformers page](https://raku.online/modules/data-transformers/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Data::Transformers   # or: zef install Data::Transformers
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Accumulating and rescaling | checked |
| [`02-arrays.raku`](02-arrays.raku) | Padding and centring | checked |
| [`03-purity.raku`](03-purity.raku) | Purity | checked |
| [`04-flat-trap.raku`](04-flat-trap.raku) | The one thing to know | checked |
