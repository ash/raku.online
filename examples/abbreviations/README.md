# Abbreviations — the examples

Every example from [the Abbreviations page](https://raku.online/modules/abbreviations/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Abbreviations   # or: zef install Abbreviations
rakupp 01-shapes.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-shapes.raku`](01-shapes.raku) | The shapes | checked |
| [`02-one-word.raku`](02-one-word.raku) | The one thing to know | checked |
