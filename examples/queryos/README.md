# QueryOS — the examples

Every example from [the QueryOS page](https://raku.online/modules/queryos/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install QueryOS   # or: zef install QueryOS
rakupp 01-os.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-os.raku`](01-os.raku) | Asking about the host | checked |
| [`02-parts.raku`](02-parts.raku) | Splitting a version string | checked |
| [`03-vnum-trap.raku`](03-vnum-trap.raku) | The one thing to know | checked |
