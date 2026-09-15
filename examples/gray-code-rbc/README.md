# Gray::Code::RBC — the examples

Every example from [the Gray::Code::RBC page](https://raku.online/modules/gray-code-rbc/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Gray::Code::RBC   # or: zef install Gray::Code::RBC
rakupp 01-gray.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-gray.raku`](01-gray.raku) | Encoding and decoding | checked |
| [`02-hamming.raku`](02-hamming.raku) | Encoding and decoding | checked |
| [`03-big.raku`](03-big.raku) | Arbitrary precision | checked |
| [`04-negative-trap.raku`](04-negative-trap.raku) | The one thing to know | checked |
