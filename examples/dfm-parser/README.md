# DFM::Parser — the examples

Every example from [the DFM::Parser page](https://raku.online/modules/dfm-parser/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install DFM::Parser   # or: zef install DFM::Parser
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Parsing | checked |
| [`02-number-list.raku`](02-number-list.raku) | The one thing to know | checked |
| [`03-failures.raku`](03-failures.raku) | Every failure is `Nil` | checked |
| [`04-lax.raku`](04-lax.raku) | What the grammar does not check | checked |
| [`05-dset.raku`](05-dset.raku) | Where the two engines differ | checked |
