# Data::Geographics — the examples

Every example from [the Data::Geographics page](https://raku.online/modules/data-geographics/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Data::Geographics   # or: zef install Data::Geographics
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Countries and cities | checked |
| [`02-distance.raku`](02-distance.raku) | Distance | checked |
| [`03-geohash.raku`](03-geohash.raku) | The one thing to know | checked |
| [`04-fields.raku`](04-fields.raku) | The field whitelist is one arbitrary country's keys | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
