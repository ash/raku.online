# DateTime::Math — the examples

Every example from [the DateTime::Math page](https://raku.online/modules/datetime-math/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install DateTime::Math   # or: zef install DateTime::Math
rakupp 01-units.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-units.raku`](01-units.raku) | Converting units | checked |
| [`02-operators.raku`](02-operators.raku) | The operators | checked |
| [`03-core-minus.raku`](03-core-minus.raku) | The operators | checked |
| [`04-calendar-trap.raku`](04-calendar-trap.raku) | The one thing to know | checked |
