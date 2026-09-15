# UK::Sort — the examples

Every example from [the UK::Sort page](https://raku.online/modules/uk-sort/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install UK::Sort   # or: zef install UK::Sort
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Sorting | checked |
| [`02-alphabet.raku`](02-alphabet.raku) | Sorting | checked |
| [`03-cmp.raku`](03-cmp.raku) | The comparator | checked |
| [`04-coll.raku`](04-coll.raku) | The one thing to know | checked |
| [`05-types.raku`](05-types.raku) | Where the two engines differ | checked |
