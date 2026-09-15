# Date::Calendar::MayaAztec — the examples

Every example from [the Date::Calendar::MayaAztec page](https://raku.online/modules/date-calendar-mayaaztec/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Date::Calendar::MayaAztec   # or: zef install Date::Calendar::MayaAztec
rakupp 01-cycles.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-cycles.raku`](01-cycles.raku) | A day under every cycle | checked |
| [`02-variants.raku`](02-variants.raku) | A day under every cycle | checked |
| [`03-locale.raku`](03-locale.raku) | Locales | checked |
| [`04-ambiguous.raku`](04-ambiguous.raku) | The one thing to know | checked |
| [`05-floor.raku`](05-floor.raku) | Where the two engines differ | checked |
