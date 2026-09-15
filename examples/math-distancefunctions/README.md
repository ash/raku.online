# Math::DistanceFunctions — the examples

Every example from [the Math::DistanceFunctions page](https://raku.online/modules/math-distancefunctions/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Math::DistanceFunctions   # or: zef install Math::DistanceFunctions
rakupp 01-kernels.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-kernels.raku`](01-kernels.raku) | Ten kernels | checked |
| [`02-infinity-norm.raku`](02-infinity-norm.raku) | The one thing to know | checked |
