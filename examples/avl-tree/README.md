# AVL-Tree — the examples

Every example from [the AVL-Tree page](https://raku.online/modules/avl-tree/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install AVL-Tree   # or: zef install AVL-Tree
rakupp 01-insert.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-insert.raku`](01-insert.raku) | Building a tree | checked |
| [`02-payload.raku`](02-payload.raku) | Payloads and deletion | checked |
| [`03-returns.raku`](03-returns.raku) | Return values | checked |
| [`04-find-trap.raku`](04-find-trap.raku) | The one thing to know | checked |
