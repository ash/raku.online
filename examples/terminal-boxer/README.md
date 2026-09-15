# Terminal::Boxer — the examples

Every example from [the Terminal::Boxer page](https://raku.online/modules/terminal-boxer/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Terminal::Boxer   # or: zef install Terminal::Boxer
rakupp 01-grid.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-grid.raku`](01-grid.raku) | Drawing a grid | checked |
| [`02-options.raku`](02-options.raku) | The named arguments | checked |
| [`03-cell-trap.raku`](03-cell-trap.raku) | The one thing to know | checked |
| [`04-aoa.raku`](04-aoa.raku) | Where the two engines differ | checked |
