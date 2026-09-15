# LEB128 — the examples

Every example from [the LEB128 page](https://raku.online/modules/leb128/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install LEB128   # or: zef install LEB128
rakupp 01-leb.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-leb.raku`](01-leb.raku) | Encoding and decoding | checked |
| [`02-buffer.raku`](02-buffer.raku) | Splicing into a buffer | checked |
| [`03-malformed.raku`](03-malformed.raku) | Malformed input | checked |
| [`04-native-int.raku`](04-native-int.raku) | Where the two engines differ | checked |
