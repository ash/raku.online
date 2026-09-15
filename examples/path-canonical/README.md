# Path::Canonical — the examples

Every example from [the Path::Canonical page](https://raku.online/modules/path-canonical/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Path::Canonical   # or: zef install Path::Canonical
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Tidying | checked |
| [`02-absolute.raku`](02-absolute.raku) | The one thing to know | checked |
| [`03-symlink.raku`](03-symlink.raku) | It is not `.resolve` | checked |
| [`04-filepath.raku`](04-filepath.raku) | Where the two engines differ | checked |
