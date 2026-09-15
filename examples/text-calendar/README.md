# Text::Calendar — the examples

Every example from [the Text::Calendar page](https://raku.online/modules/text-calendar/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::Calendar   # or: zef install Text::Calendar
rakupp 01-month.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-month.raku`](01-month.raku) | One month, and a year | checked |
| [`02-year.raku`](02-year.raku) | One month, and a year | checked |
| [`03-layouts.raku`](03-layouts.raku) | The other layouts | checked |
| [`04-dataset.raku`](04-dataset.raku) | Reading the data instead of the grid | checked |
| [`05-title-trap.raku`](05-title-trap.raku) | The one thing to know | checked |
