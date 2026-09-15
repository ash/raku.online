# Getopt::Long::Grammar — the examples

Every example from [the Getopt::Long::Grammar page](https://raku.online/modules/getopt-long-grammar/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Getopt::Long::Grammar   # or: zef install Getopt::Long::Grammar
rakupp 01-interpret.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-interpret.raku`](01-interpret.raku) | Interpreting a command line | checked |
| [`02-repeat.raku`](02-repeat.raku) | Repeated options | checked |
| [`03-space-trap.raku`](03-space-trap.raku) | The one thing to know | checked |
| [`04-quoting.raku`](04-quoting.raku) | Where the two engines differ | checked |
