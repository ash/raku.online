# Algorithm::Manacher — the examples

Every example from [the Algorithm::Manacher page](https://raku.online/modules/algorithm-manacher/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Algorithm::Manacher   # or: zef install Algorithm::Manacher
rakupp 01-find.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-find.raku`](01-find.raku) | Finding palindromes | checked |
| [`02-edges.raku`](02-edges.raku) | The edges | checked |
| [`03-maximal-trap.raku`](03-maximal-trap.raku) | The one thing to know | checked |
