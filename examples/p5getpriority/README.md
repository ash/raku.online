# P5getpriority — the examples

Every example from [the P5getpriority page](https://raku.online/modules/p5getpriority/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install P5getpriority   # or: zef install P5getpriority
rakupp 01-priority.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-priority.raku`](01-priority.raku) | Reading a priority | checked |
| [`02-setpriority.raku`](02-setpriority.raku) | Writing one | checked |
| [`03-minus-one-trap.raku`](03-minus-one-trap.raku) | The one thing to know | checked |
