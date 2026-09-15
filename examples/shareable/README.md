# Shareable — the examples

Every example from [the Shareable page](https://raku.online/modules/shareable/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Shareable   # or: zef install Shareable
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Saving and loading | checked |
| [`02-store.raku`](02-store.raku) | The store file | checked |
| [`03-unlink.raku`](03-unlink.raku) | The one thing to know | checked |
| [`04-eval.raku`](04-eval.raku) | A store file is executable code | checked |
| [`05-leak.raku`](05-leak.raku) | Where the two engines differ | checked |
