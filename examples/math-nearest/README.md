# Math::Nearest — the examples

Every example from [the Math::Nearest page](https://raku.online/modules/math-nearest/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Math::Nearest   # or: zef install Math::Nearest
rakupp 01-nearest.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-nearest.raku`](01-nearest.raku) | Building a finder and asking it | checked |
| [`02-labels.raku`](02-labels.raku) | Building a finder and asking it | checked |
| [`03-backends.raku`](03-backends.raku) | The one thing to know | checked |
