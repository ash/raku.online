# Path::Finder — the examples

Every example from [the Path::Finder page](https://raku.online/modules/path-finder/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Path::Finder   # or: zef install Path::Finder
rakupp 01-find.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-find.raku`](01-find.raku) | Rules, and pruning | checked |
| [`02-skip-dir.raku`](02-skip-dir.raku) | The one thing to know | checked |
