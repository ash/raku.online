# Data::Generators — the examples

Every example from [the Data::Generators page](https://raku.online/ecosystem/data-generators/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Data::Generators   # or: zef install Data::Generators
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.5.1 (dev build) and under Rakudo 2026.06, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | varies (random) |
| [`02-words.raku`](02-words.raku) | Words | checked |
| [`03-word-types.raku`](03-word-types.raku) | Words | checked |
| [`04-names-and-titles.raku`](04-names-and-titles.raku) | Words | varies (random) |
| [`05-strings.raku`](05-strings.raku) | Strings with a shape | checked |
| [`06-reals.raku`](06-reals.raku) | Numbers and date-times | checked |
| [`07-date-times.raku`](07-date-times.raku) | Numbers and date-times | checked |
| [`08-dataset.raku`](08-dataset.raku) | Whole tabular datasets | checked |
| [`09-dataset-generators.raku`](09-dataset-generators.raku) | Whole tabular datasets | checked |
