# ASCII::To::Uni — the examples

Every example from [the ASCII::To::Uni page](https://raku.online/modules/ascii-to-uni/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install ASCII::To::Uni   # or: zef install ASCII::To::Uni
rakupp 01-convert.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-convert.raku`](01-convert.raku) | Converting a string | checked |
| [`02-table.raku`](02-table.raku) | Your own table | checked |
| [`03-plus-trap.raku`](03-plus-trap.raku) | The one thing to know | checked |
