# Text::Lorem — the examples

Every example from [the Text::Lorem page](https://raku.online/modules/text-lorem/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::Lorem   # or: zef install Text::Lorem
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | The three methods | checked |
| [`02-instance.raku`](02-instance.raku) | The three methods | checked |
| [`03-zero.raku`](03-zero.raku) | The odd one out | checked |
| [`04-cap.raku`](04-cap.raku) | The one thing to know | checked |
| [`05-vocabulary.raku`](05-vocabulary.raku) | Where the two engines differ | checked |
