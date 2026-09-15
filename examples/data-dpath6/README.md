# Data::DPath6 — the examples

Every example from [the Data::DPath6 page](https://raku.online/modules/data-dpath6/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Data::DPath6   # or: zef install Data::DPath6
rakupp 01-whole-api.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-whole-api.raku`](01-whole-api.raku) | The whole API | checked |
| [`02-not-there.raku`](02-not-there.raku) | The one thing to know | checked |
| [`03-alternative.raku`](03-alternative.raku) | What to use instead | checked |
| [`04-metadata.raku`](04-metadata.raku) | Where the two engines differ | checked |
