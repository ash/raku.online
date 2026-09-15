# path-coverage — the examples

Every example from [the path-coverage page](https://raku.online/modules/path-coverage/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install path-coverage   # or: zef install path-coverage
rakupp 01-coverage.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-coverage.raku`](01-coverage.raku) | What they print | checked |
| [`02-blind.raku`](02-blind.raku) | The one thing to know | checked |
| [`03-quirks.raku`](03-quirks.raku) | Two more things it gets wrong | checked |
| [`04-grammar.raku`](04-grammar.raku) | Where the two engines differ | checked |
