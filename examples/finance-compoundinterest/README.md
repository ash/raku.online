# Finance::CompoundInterest — the examples

Every example from [the Finance::CompoundInterest page](https://raku.online/modules/finance-compoundinterest/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Finance::CompoundInterest   # or: zef install Finance::CompoundInterest
rakupp 01-finance.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-finance.raku`](01-finance.raku) | The four formulas | checked |
| [`02-simple.raku`](02-simple.raku) | A case you can verify by hand | checked |
| [`03-rat-trap.raku`](03-rat-trap.raku) | The one thing to know | checked |
