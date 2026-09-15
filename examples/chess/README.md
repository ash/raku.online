# Chess — the examples

Every example from [the Chess page](https://raku.online/modules/chess/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Chess   # or: zef install Chess
rakupp 01-show.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-show.raku`](01-show.raku) | Drawing a position | checked |
| [`02-fen.raku`](02-fen.raku) | Reading a position | checked |
| [`03-pgn.raku`](03-pgn.raku) | Reading a game | checked |
| [`04-shape-trap.raku`](04-shape-trap.raku) | The one thing to know | checked |
