# File::Temp — the examples

Every example from [the File::Temp page](https://raku.online/modules/file-temp/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install File::Temp   # or: zef install File::Temp
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.7.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | checked |
| [`02-named.raku`](02-named.raku) | Naming it something recognisable | checked |
| [`03-tempdir.raku`](03-tempdir.raku) | Directories | checked |
| [`04-cleanup.raku`](04-cleanup.raku) | Who removes what, and when | checked |
