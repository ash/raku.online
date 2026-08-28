# Color — the examples

Every example from [the Color page](https://raku.online/modules/color/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Color   # or: zef install Color
rakupp 01-one-color.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-one-color.raku`](01-one-color.raku) | What it is for | checked |
| [`02-palette.raku`](02-palette.raku) | This, but darker | checked |
| [`03-operators.raku`](03-operators.raku) | Color arithmetic | checked |
