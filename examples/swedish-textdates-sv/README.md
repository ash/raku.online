# Swedish::TextDates_sv — the examples

Every example from [the Swedish::TextDates_sv page](https://raku.online/modules/swedish-textdates-sv/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Swedish::TextDates_sv   # or: zef install Swedish::TextDates_sv
rakupp 01-dates.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-dates.raku`](01-dates.raku) | Spelling a date out | checked |
| [`02-weekdays.raku`](02-weekdays.raku) | Weekday names | checked |
| [`03-types.raku`](03-types.raku) | What comes back is not a Str | checked |
| [`04-exit.raku`](04-exit.raku) | The one thing to know | checked |
| [`05-enum.raku`](05-enum.raku) | Where the two engines differ | checked |
