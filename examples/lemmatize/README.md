# lemmatize — the examples

Every example from [the lemmatize page](https://raku.online/modules/lemmatize/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install lemmatize   # or: zef install lemmatize
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Loading a table and using it | checked |
| [`02-pronouns.raku`](02-pronouns.raku) | The one thing to know | checked |
| [`03-shapes.raku`](03-shapes.raku) | Two shapes to plan around | checked |
| [`04-duplicates.raku`](04-duplicates.raku) | Where the two engines differ | checked |
