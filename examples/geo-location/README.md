# Geo::Location — the examples

Every example from [the Geo::Location page](https://raku.online/modules/geo-location/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Geo::Location   # or: zef install Geo::Location
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Building and rendering | checked |
| [`02-sources.raku`](02-sources.raku) | From JSON, or from the environment | checked |
| [`03-one-coordinate.raku`](03-one-coordinate.raku) | The one thing to know | checked |
| [`04-validation.raku`](04-validation.raku) | No validation, and rounded seconds | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
