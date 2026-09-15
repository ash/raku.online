# wordfinder — the examples

Every example from [the wordfinder page](https://raku.online/modules/wordfinder/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install wordfinder   # or: zef install wordfinder
rakupp 01-array.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-array.raku`](01-array.raku) | Matching against a list | checked |
| [`02-file.raku`](02-file.raku) | Matching against a file | checked |
| [`03-bundled.raku`](03-bundled.raku) | The one thing to know | checked |
| [`04-semantics.raku`](04-semantics.raku) | The matcher is not "contains" | checked |
| [`05-arity.raku`](05-arity.raku) | Where the two engines differ | checked |
