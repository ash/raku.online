# PathTools — the examples

Every example from [the PathTools page](https://raku.online/modules/pathtools/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install PathTools   # or: zef install PathTools
rakupp 01-ls.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-ls.raku`](01-ls.raku) | Listing and creating | checked |
| [`02-mktemp.raku`](02-mktemp.raku) | Temporary paths | checked |
| [`03-recursion-trap.raku`](03-recursion-trap.raku) | The one thing to know | checked |
