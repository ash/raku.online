# Data::Tree — the examples

Every example from [the Data::Tree page](https://raku.online/modules/data-tree/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Data::Tree   # or: zef install Data::Tree
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Building and walking | checked |
| [`02-unfold.raku`](02-unfold.raku) | Building and walking | checked |
| [`03-falsy-root.raku`](03-falsy-root.raku) | The one thing to know | checked |
| [`04-names.raku`](04-names.raku) | The names are not what you type | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
