# Image::PNG::Inflated — the examples

Every example from [the Image::PNG::Inflated page](https://raku.online/modules/image-png-inflated/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Image::PNG::Inflated   # or: zef install Image::PNG::Inflated
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Writing one | checked |
| [`02-dimensions.raku`](02-dimensions.raku) | The dimensions are required | checked |
| [`03-lying-header.raku`](03-lying-header.raku) | The one thing to know | checked |
| [`04-chunking.raku`](04-chunking.raku) | Where the two engines differ | checked |
