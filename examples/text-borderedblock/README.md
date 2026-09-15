# Text::BorderedBlock — the examples

Every example from [the Text::BorderedBlock page](https://raku.online/modules/text-borderedblock/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::BorderedBlock   # or: zef install Text::BorderedBlock
rakupp 01-box.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-box.raku`](01-box.raku) | Boxing a block | checked |
| [`02-width.raku`](02-width.raku) | How the width is chosen | checked |
| [`03-width-trap.raku`](03-width-trap.raku) | The one thing to know | checked |
