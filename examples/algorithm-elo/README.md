# Algorithm::Elo — the examples

Every example from [the Algorithm::Elo page](https://raku.online/modules/algorithm-elo/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Algorithm::Elo   # or: zef install Algorithm::Elo
rakupp 01-elo.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-elo.raku`](01-elo.raku) | Rating a game | checked |
| [`02-flags.raku`](02-flags.raku) | The flags | checked |
| [`03-unreachable.raku`](03-unreachable.raku) | The one thing to know | checked |
