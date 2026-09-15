# P5opendir — the examples

Every example from [the P5opendir page](https://raku.online/modules/p5opendir/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install P5opendir   # or: zef install P5opendir
rakupp 01-walk.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-walk.raku`](01-walk.raku) | Walking a directory | checked |
| [`02-list.raku`](02-list.raku) | The list form | checked |
| [`03-splice-trap.raku`](03-splice-trap.raku) | The one thing to know | checked |
