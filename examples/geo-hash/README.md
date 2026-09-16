# Geo::Hash — the examples

Every example from [the Geo::Hash page](https://raku.online/modules/geo-hash/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Geo::Hash   # or: zef install Geo::Hash
rakupp 01-geohash-roundtrip.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-geohash-roundtrip.raku`](01-geohash-roundtrip.raku) | Encoding and decoding | checked |
| [`02-geohash-precision.raku`](02-geohash-precision.raku) | Precision is the length of the string | checked |
| [`03-geohash-prefix.raku`](03-geohash-prefix.raku) | The prefix property | checked |
