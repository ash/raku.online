# Data::Dump — the examples

Every example from [the Data::Dump page](https://raku.online/modules/data-dump/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Data::Dump   # or: zef install Data::Dump
rakupp 01-dump-a-structure.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-dump-a-structure.raku`](01-dump-a-structure.raku) | What it is for | checked |
