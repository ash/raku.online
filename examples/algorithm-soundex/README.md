# Algorithm::Soundex — the examples

Every example from [the Algorithm::Soundex page](https://raku.online/modules/algorithm-soundex/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Algorithm::Soundex   # or: zef install Algorithm::Soundex
rakupp 01-soundex.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-soundex.raku`](01-soundex.raku) | Coding a name | checked |
| [`02-input.raku`](02-input.raku) | What it does with the input | checked |
| [`03-short-trap.raku`](03-short-trap.raku) | The one thing to know | checked |
