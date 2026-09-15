# File::Stat — the examples

Every example from [the File::Stat page](https://raku.online/modules/file-stat/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install File::Stat   # or: zef install File::Stat
rakupp 01-fields.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-fields.raku`](01-fields.raku) | The fields | checked |
| [`02-symlinks.raku`](02-symlinks.raku) | The fields | checked |
| [`03-not-a-snapshot.raku`](03-not-a-snapshot.raku) | The one thing to know | checked |
