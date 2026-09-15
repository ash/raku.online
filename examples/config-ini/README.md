# Config::INI — the examples

Every example from [the Config::INI page](https://raku.online/modules/config-ini/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Config::INI   # or: zef install Config::INI
rakupp 01-parse.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-parse.raku`](01-parse.raku) | Reading a file | checked |
| [`02-write.raku`](02-write.raku) | Writing one | checked |
| [`03-edges.raku`](03-edges.raku) | What the grammar accepts | checked |
| [`04-newline-trap.raku`](04-newline-trap.raku) | The one thing to know | checked |
