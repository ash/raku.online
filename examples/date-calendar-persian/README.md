# Date::Calendar::Persian — the examples

Every example from [the Date::Calendar::Persian page](https://raku.online/modules/date-calendar-persian/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Date::Calendar::Persian   # or: zef install Date::Calendar::Persian
rakupp 01-persian.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-persian.raku`](01-persian.raku) | Converting a date | checked |
| [`02-nowruz.raku`](02-nowruz.raku) | Nowruz | checked |
| [`03-epoch.raku`](03-epoch.raku) | The epoch | checked |
| [`04-variants-trap.raku`](04-variants-trap.raku) | The one thing to know | checked |
