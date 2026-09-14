# Digest — the examples

Every example from [the Digest page](https://raku.online/modules/digest/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Digest   # or: zef install Digest
rakupp 01-hashes.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-hashes.raku`](01-hashes.raku) | One sub per algorithm | checked |
| [`02-shake.raku`](02-shake.raku) | One sub per algorithm | checked |
