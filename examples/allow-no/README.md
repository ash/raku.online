# allow-no — the examples

Every example from [the allow-no page](https://raku.online/modules/allow-no/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install allow-no   # or: zef install allow-no
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | What `use` changes | checked |
| [`02-separator.raku`](02-separator.raku) | The one thing to know | checked |
| [`03-leak.raku`](03-leak.raku) | It leaks, process-wide | checked |
| [`04-core.raku`](04-core.raku) | Where the two engines differ | checked |
