# Compress::LZString — the examples

Every example from [the Compress::LZString page](https://raku.online/modules/compress-lzstring/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Compress::LZString   # or: zef install Compress::LZString
rakupp 01-roundtrip.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-roundtrip.raku`](01-roundtrip.raku) | Round trips | checked |
| [`02-growth.raku`](02-growth.raku) | When it is worth using | checked |
| [`03-unicode.raku`](03-unicode.raku) | Non-ASCII | checked |
| [`04-empty-trap.raku`](04-empty-trap.raku) | The one thing to know | checked |
