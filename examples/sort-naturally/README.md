# Sort::Naturally — the examples

Every example from [the Sort::Naturally page](https://raku.online/modules/sort-naturally/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Sort::Naturally   # or: zef install Sort::Naturally
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Sorting naturally | checked |
| [`02-keys.raku`](02-keys.raku) | Sorting naturally | checked |
| [`03-padding.raku`](03-padding.raku) | The one thing to know | checked |
| [`04-p5.raku`](04-p5.raku) | The two transforms are not interchangeable | checked |
| [`05-allomorph.raku`](05-allomorph.raku) | Where the two engines differ | checked |
