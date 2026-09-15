# Algorithm::TernarySearchTree — the examples

Every example from [the Algorithm::TernarySearchTree page](https://raku.online/modules/algorithm-ternarysearchtree/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Algorithm::TernarySearchTree   # or: zef install Algorithm::TernarySearchTree
rakupp 01-tst.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tst.raku`](01-tst.raku) | Storing and finding | checked |
| [`02-partial.raku`](02-partial.raku) | The wildcard match | checked |
| [`03-fixed-length.raku`](03-fixed-length.raku) | The one thing to know | checked |
| [`04-balance.raku`](04-balance.raku) | Where the two engines differ | checked |
