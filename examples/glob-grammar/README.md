# Glob::Grammar — the examples

Every example from [the Glob::Grammar page](https://raku.online/modules/glob-grammar/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Glob::Grammar   # or: zef install Glob::Grammar
rakupp 01-translate.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-translate.raku`](01-translate.raku) | Glob in, regex source out | checked |
| [`02-brackets.raku`](02-brackets.raku) | The one thing to know | checked |
