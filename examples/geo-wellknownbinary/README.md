# Geo::WellKnownBinary — the examples

Every example from [the Geo::WellKnownBinary page](https://raku.online/modules/geo-wellknownbinary/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Geo::WellKnownBinary   # or: zef install Geo::WellKnownBinary
rakupp 01-point.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-point.raku`](01-point.raku) | Decoding a point | checked |
| [`02-shapes.raku`](02-shapes.raku) | Lines and polygons | checked |
| [`03-lenient.raku`](03-lenient.raku) | The one thing to know | checked |
| [`04-truncated.raku`](04-truncated.raku) | Where the two engines differ | checked |
