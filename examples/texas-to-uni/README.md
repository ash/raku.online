# Texas::To::Uni — the examples

Every example from [the Texas::To::Uni page](https://raku.online/modules/texas-to-uni/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Texas::To::Uni   # or: zef install Texas::To::Uni
rakupp 01-string.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-string.raku`](01-string.raku) | Converting a string | checked |
| [`02-table.raku`](02-table.raku) | Converting a string | checked |
| [`03-file.raku`](03-file.raku) | Converting a file | checked |
| [`04-damage.raku`](04-damage.raku) | What it will do to your source | checked |
| [`05-order.raku`](05-order.raku) | The one thing to know | checked |
| [`06-portable.raku`](06-portable.raku) | Where the two engines differ | checked |
