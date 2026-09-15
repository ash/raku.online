# Statistics::LinearRegression — the examples

Every example from [the Statistics::LinearRegression page](https://raku.online/modules/statistics-linearregression/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Statistics::LinearRegression   # or: zef install Statistics::LinearRegression
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Fitting | checked |
| [`02-two-forms.raku`](02-two-forms.raku) | Fitting | checked |
| [`03-degenerate.raku`](03-degenerate.raku) | The one thing to know | checked |
| [`04-mismatch.raku`](04-mismatch.raku) | No length check | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
