# Algorithm::LCS — the examples

Every example from [the Algorithm::LCS page](https://raku.online/modules/algorithm-lcs/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Algorithm::LCS   # or: zef install Algorithm::LCS
rakupp 01-lcs.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-lcs.raku`](01-lcs.raku) | Finding the subsequence | checked |
| [`02-compare.raku`](02-compare.raku) | Choosing how elements compare | checked |
| [`03-asymmetry.raku`](03-asymmetry.raku) | The one thing to know | checked |
