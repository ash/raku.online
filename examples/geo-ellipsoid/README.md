# Geo::Ellipsoid — the examples

Every example from [the Geo::Ellipsoid page](https://raku.online/modules/geo-ellipsoid/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Geo::Ellipsoid   # or: zef install Geo::Ellipsoid
rakupp 01-range.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-range.raku`](01-range.raku) | Distance and bearing | checked |
| [`02-at.raku`](02-at.raku) | Going the other way | checked |
| [`03-units.raku`](03-units.raku) | Other units and other ellipsoids | checked |
| [`04-order-trap.raku`](04-order-trap.raku) | The one thing to know | checked |
