# Math::DistanceFunctions::Edit — the examples

Every example from [the Math::DistanceFunctions::Edit page](https://raku.online/modules/math-distancefunctions-edit/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Math::DistanceFunctions::Edit   # or: zef install Math::DistanceFunctions::Edit
rakupp 01-distance.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-distance.raku`](01-distance.raku) | Two subs | checked |
| [`02-graphemes.raku`](02-graphemes.raku) | Two subs | checked |
| [`03-not-a-metric.raku`](03-not-a-metric.raku) | The one thing to know | checked |
