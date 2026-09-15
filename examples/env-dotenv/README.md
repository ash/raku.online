# Env::Dotenv — the examples

Every example from [the Env::Dotenv page](https://raku.online/modules/env-dotenv/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Env::Dotenv   # or: zef install Env::Dotenv
rakupp 01-load.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-load.raku`](01-load.raku) | Loading a file | checked |
| [`02-equals-trap.raku`](02-equals-trap.raku) | The one thing to know | checked |
