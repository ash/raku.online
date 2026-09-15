# Math::DistanceFunctions::Native — the examples

Every example from [the Math::DistanceFunctions::Native page](https://raku.online/modules/math-distancefunctions-native/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Math::DistanceFunctions::Native   # or: zef install Math::DistanceFunctions::Native
rakupp 01-distances.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-distances.raku`](01-distances.raku) | The distances | checked |
| [`02-identical.raku`](02-identical.raku) | Identical vectors | checked |
| [`03-nan-trap.raku`](03-nan-trap.raku) | The one thing to know | checked |
