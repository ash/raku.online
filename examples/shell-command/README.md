# Shell::Command — the examples

Every example from [the Shell::Command page](https://raku.online/modules/shell-command/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Shell::Command   # or: zef install Shell::Command
rakupp 01-cp-and-rm.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-cp-and-rm.raku`](01-cp-and-rm.raku) | What it is for | checked |
| [`02-cat-and-which.raku`](02-cat-and-which.raku) | The rest of the toolbox | checked |
