# Text::Homoglyph — the examples

Every example from [the Text::Homoglyph page](https://raku.online/modules/text-homoglyph/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::Homoglyph   # or: zef install Text::Homoglyph
rakupp 01-lookup.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-lookup.raku`](01-lookup.raku) | The whole API | checked |
| [`02-coverage.raku`](02-coverage.raku) | The whole API | checked |
| [`03-guard.raku`](03-guard.raku) | The one thing to know | checked |
| [`04-asymmetry.raku`](04-asymmetry.raku) | Where the two engines differ | checked |
