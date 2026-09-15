# Date::Calendar::Armenian — the examples

Every example from [the Date::Calendar::Armenian page](https://raku.online/modules/date-calendar-armenian/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Date::Calendar::Armenian   # or: zef install Date::Calendar::Armenian
rakupp 01-convert.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-convert.raku`](01-convert.raku) | Converting | checked |
| [`02-year.raku`](02-year.raku) | The shape of the year | checked |
| [`03-slide.raku`](03-slide.raku) | The one thing to know | checked |
| [`04-dow.raku`](04-dow.raku) | Where the two engines differ | checked |
