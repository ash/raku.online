# Encoding::Huffman::PP6 — the examples

Every example from [the Encoding::Huffman::PP6 page](https://raku.online/modules/encoding-huffman-pp6/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Encoding::Huffman::PP6   # or: zef install Encoding::Huffman::PP6
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Encoding | checked |
| [`02-custom.raku`](02-custom.raku) | Encoding | checked |
| [`03-digits.raku`](03-digits.raku) | The one thing to know | checked |
| [`04-garbage.raku`](04-garbage.raku) | Any byte sequence is "valid input" | checked |
| [`05-hpack.raku`](05-hpack.raku) | It is not HPACK-compatible | checked |
| [`06-portable.raku`](06-portable.raku) | Where the two engines differ | checked |
