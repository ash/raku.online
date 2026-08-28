# UUID — the examples

Every example from [the UUID page](https://raku.online/modules/uuid/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install UUID   # or: zef install UUID
rakupp 01-mint-one.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-mint-one.raku`](01-mint-one.raku) | What it is for | varies (random) |
| [`02-format-guarantees.raku`](02-format-guarantees.raku) | What the format promises | checked |
