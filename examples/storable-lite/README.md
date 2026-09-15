# Storable::Lite — the examples

Every example from [the Storable::Lite page](https://raku.online/modules/storable-lite/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Storable::Lite   # or: zef install Storable::Lite
rakupp 01-store.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-store.raku`](01-store.raku) | Saving and loading | checked |
| [`02-format.raku`](02-format.raku) | What the file holds | checked |
| [`03-role.raku`](03-role.raku) | The role | checked |
