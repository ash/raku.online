# head-skip-tail — the examples

Every example from [the head-skip-tail page](https://raku.online/modules/head-skip-tail/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install head-skip-tail   # or: zef install head-skip-tail
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | The three subs | checked |
| [`02-shapes.raku`](02-shapes.raku) | The argument shapes | checked |
| [`03-collision.raku`](03-collision.raku) | The one thing to know | checked |
| [`04-guard.raku`](04-guard.raku) | Where the two engines differ | checked |
