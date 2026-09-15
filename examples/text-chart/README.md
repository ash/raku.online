# Text::Chart — the examples

Every example from [the Text::Chart page](https://raku.online/modules/text-chart/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::Chart   # or: zef install Text::Chart
rakupp 01-vertical.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-vertical.raku`](01-vertical.raku) | Drawing a chart | checked |
| [`02-chars.raku`](02-chars.raku) | Drawing a chart | checked |
| [`03-shapes.raku`](03-shapes.raku) | What comes back | checked |
| [`04-width.raku`](04-width.raku) | The one thing to know | checked |
| [`05-nonnumeric.raku`](05-nonnumeric.raku) | Where the two engines differ | checked |
