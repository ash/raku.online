# Astro::Sunrise — the examples

Every example from [the Astro::Sunrise page](https://raku.online/modules/astro-sunrise/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Astro::Sunrise   # or: zef install Astro::Sunrise
rakupp 01-sunrise.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-sunrise.raku`](01-sunrise.raku) | Sunrise and sunset | checked |
| [`02-altitude.raku`](02-altitude.raku) | Choosing an altitude | checked |
| [`03-polar.raku`](03-polar.raku) | When the sun does not rise | checked |
| [`04-order-trap.raku`](04-order-trap.raku) | The one thing to know | checked |
| [`05-iter.raku`](05-iter.raku) | Where the two engines differ | checked |
