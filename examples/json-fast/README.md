# JSON::Fast — the examples

Every example from [the JSON::Fast page](https://raku.online/ecosystem/json-fast/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install JSON::Fast   # or: zef install JSON::Fast
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.7.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | checked |
| [`02-types.raku`](02-types.raku) | Reading: the types you get back | checked |
| [`03-pretty.raku`](03-pretty.raku) | Writing: `to-json` and its three adverbs | checked |
| [`04-spacing.raku`](04-spacing.raku) | Writing: `to-json` and its three adverbs | checked |
| [`05-import-form.raku`](05-import-form.raku) | Writing: `to-json` and its three adverbs | checked |
| [`06-immutable.raku`](06-immutable.raku) | `:immutable` — a result nobody can edit under you | checked |
| [`07-jsonc.raku`](07-jsonc.raku) | JSON with comments | checked |
| [`08-errors.raku`](08-errors.raku) | When the text is wrong | checked |
| [`09-unicode.raku`](09-unicode.raku) | Unicode, and the pair of escapes above U+FFFF | checked |
