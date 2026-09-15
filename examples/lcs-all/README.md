# LCS::All — the examples

Every example from [the LCS::All page](https://raku.online/modules/lcs-all/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install LCS::All   # or: zef install LCS::All
rakupp 01-all.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-all.raku`](01-all.raku) | Every alignment | checked |
| [`02-recover.raku`](02-recover.raku) | Recovering the elements | checked |
| [`03-depth-trap.raku`](03-depth-trap.raku) | The one thing to know | checked |
