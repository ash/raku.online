# Unicode::PRECIS — the examples

Every example from [the Unicode::PRECIS page](https://raku.online/modules/unicode-precis/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Unicode::PRECIS   # or: zef install Unicode::PRECIS
rakupp 01-enforce.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-enforce.raku`](01-enforce.raku) | Enforcing a profile | checked |
| [`02-compare.raku`](02-compare.raku) | Comparison | checked |
| [`03-width-trap.raku`](03-width-trap.raku) | The one thing to know | checked |
