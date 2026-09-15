# Digest::FNV — the examples

Every example from [the Digest::FNV page](https://raku.online/modules/digest-fnv/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Digest::FNV   # or: zef install Digest::FNV
rakupp 01-fnv.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-fnv.raku`](01-fnv.raku) | Hashing | checked |
| [`02-widths.raku`](02-widths.raku) | Widths and variants | checked |
| [`03-mask-trap.raku`](03-mask-trap.raku) | The one thing to know | checked |
