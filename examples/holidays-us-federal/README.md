# Holidays::US::Federal — the examples

Every example from [the Holidays::US::Federal page](https://raku.online/modules/holidays-us-federal/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Holidays::US::Federal   # or: zef install Holidays::US::Federal
rakupp 01-holidays.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-holidays.raku`](01-holidays.raku) | A year of holidays | checked |
| [`02-count.raku`](02-count.raku) | Counting the shifts | checked |
| [`03-shape-trap.raku`](03-shape-trap.raku) | The one thing to know | checked |
| [`04-no-validation.raku`](04-no-validation.raku) | Where the two engines differ | checked |
