# Color::Scheme — the examples

Every example from [the Color::Scheme page](https://raku.online/modules/color-scheme/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Color::Scheme   # or: zef install Color::Scheme
rakupp 01-scheme.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-scheme.raku`](01-scheme.raku) | Generating a palette | checked |
| [`02-angles.raku`](02-angles.raku) | Your own angles | checked |
| [`03-names.raku`](03-names.raku) | The seventeen names | checked |
| [`04-debug-trap.raku`](04-debug-trap.raku) | The one thing to know | checked |
