# Browser::Open — the examples

Every example from [the Browser::Open page](https://raku.online/modules/browser-open/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Browser::Open   # or: zef install Browser::Open
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Asking what it would run | checked |
| [`02-browser-env.raku`](02-browser-env.raku) | The one thing to know | checked |
| [`03-silent.raku`](03-silent.raku) | Failure is silent | checked |
| [`04-table.raku`](04-table.raku) | Where the two engines differ | checked |
