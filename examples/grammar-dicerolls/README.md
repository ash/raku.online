# Grammar::DiceRolls — the examples

Every example from [the Grammar::DiceRolls page](https://raku.online/modules/grammar-dicerolls/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Grammar::DiceRolls   # or: zef install Grammar::DiceRolls
rakupp 01-parse.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-parse.raku`](01-parse.raku) | Parsing the notation | checked |
| [`02-roll.raku`](02-roll.raku) | Rolling | checked |
| [`03-limits.raku`](03-limits.raku) | Limits | checked |
| [`04-reuse-trap.raku`](04-reuse-trap.raku) | The one thing to know | checked |
