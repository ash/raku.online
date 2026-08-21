# Statistics::Distributions — the examples

Every example from [the Statistics::Distributions page](https://raku.online/ecosystem/statistics-distributions/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Statistics::Distributions   # or: zef install Statistics::Distributions
rakupp 01-catalogue.raku
```

Each file is run under Raku++ 3.5.1 (dev build) and under Rakudo 2026.07, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-catalogue.raku`](01-catalogue.raku) | What it is for | checked |
| [`02-first-draw.raku`](02-first-draw.raku) | Your first draw | varies (random) |
| [`03-draw-shape.raku`](03-draw-shape.raku) | Your first draw | checked |
| [`04-reuse-a-distribution.raku`](04-reuse-a-distribution.raku) | Your first draw | varies (random) |
| [`05-parameters.raku`](05-parameters.raku) | Naming the parameters | checked |
| [`06-dice.raku`](06-dice.raku) | Discrete draws | checked |
| [`07-biased-coin.raku`](07-biased-coin.raku) | Discrete draws | checked |
| [`08-uniform.raku`](08-uniform.raku) | Uniform, and the range it draws from | checked |
| [`09-quantiles.raku`](09-quantiles.raku) | Reading quantiles off data you already have | checked |
| [`10-mixture.raku`](10-mixture.raku) | Mixtures and products | checked |
| [`11-product.raku`](11-product.raku) | Mixtures and products | checked |
| [`12-response-times.raku`](12-response-times.raku) | A worked example: a day of response times | varies (random) |
| [`13-response-time-assertions.raku`](13-response-time-assertions.raku) | A worked example: a day of response times | checked |
| [`14-srand.raku`](14-srand.raku) | Where the two engines differ | varies (random) |
