# Util::Bitfield — the examples

Every example from [the Util::Bitfield page](https://raku.online/modules/util-bitfield/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Util::Bitfield   # or: zef install Util::Bitfield
rakupp 01-extract.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-extract.raku`](01-extract.raku) | Extracting a field | checked |
| [`02-mask.raku`](02-mask.raku) | Masks and insertion | checked |
| [`03-split.raku`](03-split.raku) | Splitting a value into bits | checked |
| [`04-list-trap.raku`](04-list-trap.raku) | The one thing to know | checked |
