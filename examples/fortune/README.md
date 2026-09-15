# Fortune — the examples

Every example from [the Fortune page](https://raku.online/modules/fortune/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Fortune   # or: zef install Fortune
rakupp 01-fortune.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-fortune.raku`](01-fortune.raku) | Drawing a fortune | checked |
| [`02-own.raku`](02-own.raku) | Your own database | checked |
| [`03-nil-trap.raku`](03-nil-trap.raku) | The one thing to know | checked |
