# EuclideanRhythm — the examples

Every example from [the EuclideanRhythm page](https://raku.online/modules/euclideanrhythm/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install EuclideanRhythm   # or: zef install EuclideanRhythm
rakupp 01-rhythm.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-rhythm.raku`](01-rhythm.raku) | Generating a bar | checked |
| [`02-list.raku`](02-list.raku) | The repeating form | checked |
| [`03-constructor.raku`](03-constructor.raku) | The constructor | checked |
