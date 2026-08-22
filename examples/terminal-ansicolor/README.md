# Terminal::ANSIColor — the examples

Every example from [the Terminal::ANSIColor page](https://raku.online/ecosystem/terminal-ansicolor/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Terminal::ANSIColor   # or: zef install Terminal::ANSIColor
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.6.0 (dev build) and under Rakudo 2026.07, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | checked |
| [`02-attributes.raku`](02-attributes.raku) | Attributes, and how they combine | checked |
| [`03-palette.raku`](03-palette.raku) | 256 colours | checked |
| [`04-strip.raku`](04-strip.raku) | Taking it off again | checked |
| [`05-table.raku`](05-table.raku) | Taking it off again | checked |
