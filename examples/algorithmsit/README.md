# AlgorithmsIT — the examples

Every example from [the AlgorithmsIT page](https://raku.online/modules/algorithmsit/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install AlgorithmsIT   # or: zef install AlgorithmsIT
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Matching | checked |
| [`02-prefix.raku`](02-prefix.raku) | Matching | checked |
| [`03-onebased.raku`](03-onebased.raku) | `ArrayOneBased` | checked |
| [`04-iterable.raku`](04-iterable.raku) | The one thing to know | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
