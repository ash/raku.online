# Algorithm::BinaryIndexedTree — the examples

Every example from [the Algorithm::BinaryIndexedTree page](https://raku.online/modules/algorithm-binaryindexedtree/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Algorithm::BinaryIndexedTree   # or: zef install Algorithm::BinaryIndexedTree
rakupp 01-fenwick.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-fenwick.raku`](01-fenwick.raku) | Building and querying | checked |
| [`02-update.raku`](02-update.raku) | Updating | checked |
| [`03-bounds.raku`](03-bounds.raku) | The bounds | checked |
| [`04-zero-trap.raku`](04-zero-trap.raku) | The one thing to know | checked |
