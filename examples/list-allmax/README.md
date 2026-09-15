# List::Allmax — the examples

Every example from [the List::Allmax page](https://raku.online/modules/list-allmax/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install List::Allmax   # or: zef install List::Allmax
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Both forms | checked |
| [`02-by.raku`](02-by.raku) | Comparing by a key | checked |
| [`03-by-calls.raku`](03-by-calls.raku) | The one thing to know | checked |
| [`04-flatten.raku`](04-flatten.raku) | Everything is flattened | checked |
| [`05-lazy.raku`](05-lazy.raku) | Where the two engines differ | checked |
