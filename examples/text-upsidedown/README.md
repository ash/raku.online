# Text::UpsideDown — the examples

Every example from [the Text::UpsideDown page](https://raku.online/modules/text-upsidedown/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::UpsideDown   # or: zef install Text::UpsideDown
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Flipping | checked |
| [`02-involution.raku`](02-involution.raku) | The one thing to know | checked |
| [`03-untouched.raku`](03-untouched.raku) | What it does not touch | checked |
| [`04-types.raku`](04-types.raku) | Where the two engines differ | checked |
