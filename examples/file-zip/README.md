# File::Zip — the examples

Every example from [the File::Zip page](https://raku.online/modules/file-zip/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install File::Zip   # or: zef install File::Zip
rakupp 01-list.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-list.raku`](01-list.raku) | Opening and listing | checked |
| [`02-extract.raku`](02-extract.raku) | Extracting | checked |
| [`03-refuses.raku`](03-refuses.raku) | What the constructor refuses | checked |
