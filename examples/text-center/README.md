# Text::Center — the examples

Every example from [the Text::Center page](https://raku.online/modules/text-center/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::Center   # or: zef install Text::Center
rakupp 01-center.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-center.raku`](01-center.raku) | Centring something | checked |
| [`02-fill.raku`](02-fill.raku) | Filling with something other than a space | checked |
| [`03-fill-trap.raku`](03-fill-trap.raku) | The one thing to know | checked |
