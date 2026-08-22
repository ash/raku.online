# File::Find — the examples

Every example from [the File::Find page](https://raku.online/ecosystem/file-find/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install File::Find   # or: zef install File::Find
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.6.0 (dev build) and under Rakudo 2026.07, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | checked |
| [`02-filters.raku`](02-filters.raku) | The filters | checked |
| [`03-lazy.raku`](03-lazy.raku) | It is lazy, and that matters | checked |
