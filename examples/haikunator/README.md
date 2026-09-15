# Haikunator — the examples

Every example from [the Haikunator page](https://raku.online/modules/haikunator/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Haikunator   # or: zef install Haikunator
rakupp 01-shape.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-shape.raku`](01-shape.raku) | Minting a name | checked |
| [`02-options.raku`](02-options.raku) | Changing the shape | checked |
| [`03-hex-trap.raku`](03-hex-trap.raku) | The one thing to know | checked |
