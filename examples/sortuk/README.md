# sortuk — the examples

Every example from [the sortuk page](https://raku.online/modules/sortuk/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install sortuk   # or: zef install sortuk
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Sorting | checked |
| [`02-candidates.raku`](02-candidates.raku) | Sorting | checked |
| [`03-missing-ts.raku`](03-missing-ts.raku) | The one thing to know | checked |
| [`04-prefix.raku`](04-prefix.raku) | Prefixes are not ordered | checked |
| [`05-cost.raku`](05-cost.raku) | Where the two engines differ | checked |
