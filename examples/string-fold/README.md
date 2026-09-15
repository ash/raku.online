# String::Fold — the examples

Every example from [the String::Fold page](https://raku.online/modules/string-fold/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install String::Fold   # or: zef install String::Fold
rakupp 01-fold.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-fold.raku`](01-fold.raku) | Folding a paragraph | checked |
| [`02-whitespace.raku`](02-whitespace.raku) | What it does to whitespace you already had | checked |
| [`03-longword.raku`](03-longword.raku) | The one thing to know | checked |
