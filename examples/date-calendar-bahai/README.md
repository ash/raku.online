# Date::Calendar::Bahai — the examples

Every example from [the Date::Calendar::Bahai page](https://raku.online/modules/date-calendar-bahai/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Date::Calendar::Bahai   # or: zef install Date::Calendar::Bahai
rakupp 01-bahai.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-bahai.raku`](01-bahai.raku) | Converting a date | checked |
| [`02-epoch.raku`](02-epoch.raku) | The epoch | checked |
| [`03-twenty-trap.raku`](03-twenty-trap.raku) | The one thing to know | checked |
| [`04-variants.raku`](04-variants.raku) | Arithmetic against astronomical | checked |
