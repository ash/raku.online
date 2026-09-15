# Game::Sudoku — the examples

Every example from [the Game::Sudoku page](https://raku.online/modules/game-sudoku/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Game::Sudoku   # or: zef install Game::Sudoku
rakupp 01-grid.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-grid.raku`](01-grid.raku) | Reading a puzzle | checked |
| [`02-cells.raku`](02-cells.raku) | Candidates and coordinates | checked |
| [`03-solve.raku`](03-solve.raku) | Solving | checked |
| [`04-given-trap.raku`](04-given-trap.raku) | The one thing to know | checked |
