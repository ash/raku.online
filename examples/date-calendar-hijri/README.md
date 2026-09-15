# Date::Calendar::Hijri — the examples

Every example from [the Date::Calendar::Hijri page](https://raku.online/modules/date-calendar-hijri/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Date::Calendar::Hijri   # or: zef install Date::Calendar::Hijri
rakupp 01-hijri.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-hijri.raku`](01-hijri.raku) | Converting a date | checked |
| [`02-epoch.raku`](02-epoch.raku) | The epoch | checked |
| [`03-dow.raku`](03-dow.raku) | Day-of-week numbering | checked |
| [`04-daypart-trap.raku`](04-daypart-trap.raku) | The one thing to know | checked |
