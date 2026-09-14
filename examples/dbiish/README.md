# DBIish — the examples

Every example from [the DBIish page](https://raku.online/modules/dbiish/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install DBIish   # or: zef install DBIish
rakupp 01-sqlite.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-sqlite.raku`](01-sqlite.raku) | Connect, insert, select | checked |
| [`02-types.raku`](02-types.raku) | Connect, insert, select | checked |
