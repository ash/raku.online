# Config — the examples

Every example from [the Config page](https://raku.online/modules/config/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Config   # or: zef install Config
rakupp 01-layers.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-layers.raku`](01-layers.raku) | Layers | checked |
| [`02-write-through.raku`](02-write-through.raku) | The one thing to know | checked |
