# Games::Maze — the examples

Every example from [the Games::Maze page](https://raku.online/modules/games-maze/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Games::Maze   # or: zef install Games::Maze
rakupp 01-maze.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-maze.raku`](01-maze.raku) | Carving a maze | checked |
| [`02-perfect.raku`](02-perfect.raku) | Is it a real maze? | checked |
| [`03-sealed.raku`](03-sealed.raku) | The one thing to know | checked |
| [`04-once.raku`](04-once.raku) | Carving happens exactly once | checked |
