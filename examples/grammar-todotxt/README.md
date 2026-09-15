# Grammar::TodoTxt — the examples

Every example from [the Grammar::TodoTxt page](https://raku.online/modules/grammar-todotxt/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Grammar::TodoTxt   # or: zef install Grammar::TodoTxt
rakupp 01-parse.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-parse.raku`](01-parse.raku) | Parsing a file | checked |
| [`02-edges.raku`](02-edges.raku) | What it accepts | checked |
| [`03-colon-trap.raku`](03-colon-trap.raku) | The one thing to know | checked |
