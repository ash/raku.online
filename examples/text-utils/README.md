# Text::Utils — the examples

Every example from [the Text::Utils page](https://raku.online/modules/text-utils/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::Utils   # or: zef install Text::Utils
rakupp 01-chores.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-chores.raku`](01-chores.raku) | The chores | checked |
| [`02-wrap.raku`](02-wrap.raku) | The chores | checked |
