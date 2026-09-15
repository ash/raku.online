# Netstring — the examples

Every example from [the Netstring page](https://raku.online/modules/netstring/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Netstring   # or: zef install Netstring
rakupp 01-frame.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-frame.raku`](01-frame.raku) | Framing a message | checked |
| [`02-buf.raku`](02-buf.raku) | Bytes out | checked |
| [`03-blob-trap.raku`](03-blob-trap.raku) | The one thing to know | checked |
| [`04-reader.raku`](04-reader.raku) | Where the two engines differ | checked |
