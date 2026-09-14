# UUID::V4 — the examples

Every example from [the UUID::V4 page](https://raku.online/modules/uuid-v4/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install UUID::V4   # or: zef install UUID::V4
rakupp 01-mint.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-mint.raku`](01-mint.raku) | Both subs | checked |
| [`02-bias.raku`](02-bias.raku) | The one thing to know | checked |
