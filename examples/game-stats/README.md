# Game::Stats — the examples

Every example from [the Game::Stats page](https://raku.online/modules/game-stats/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Game::Stats   # or: zef install Game::Stats
rakupp 01-samples.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-samples.raku`](01-samples.raku) | Samples and their moments | checked |
| [`02-probability.raku`](02-probability.raku) | Samples and their moments | checked |
| [`03-spelling.raku`](03-spelling.raku) | The one thing to know | checked |
