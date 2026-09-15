# Mortgage — the examples

Every example from [the Mortgage page](https://raku.online/modules/mortgage/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Mortgage   # or: zef install Mortgage
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | The formulas | checked |
| [`02-period.raku`](02-period.raku) | The one thing to know | checked |
| [`03-rate-trap.raku`](03-rate-trap.raku) | The one thing to know | checked |
| [`04-class.raku`](04-class.raku) | The class | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
