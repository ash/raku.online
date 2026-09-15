# Algorithm::ZobristHashing — the examples

Every example from [the Algorithm::ZobristHashing page](https://raku.online/modules/algorithm-zobristhashing/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Algorithm::ZobristHashing   # or: zef install Algorithm::ZobristHashing
rakupp 01-zobrist.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-zobrist.raku`](01-zobrist.raku) | Hashing a board | checked |
| [`02-incremental.raku`](02-incremental.raku) | The incremental update | checked |
| [`03-input.raku`](03-input.raku) | What counts as input | checked |
| [`04-width-trap.raku`](04-width-trap.raku) | The one thing to know | checked |
