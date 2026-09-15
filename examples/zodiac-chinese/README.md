# Zodiac::Chinese — the examples

Every example from [the Zodiac::Chinese page](https://raku.online/modules/zodiac-chinese/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Zodiac::Chinese   # or: zef install Zodiac::Chinese
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Using it | checked |
| [`02-cycle.raku`](02-cycle.raku) | The cycle is genuinely sixty long | checked |
| [`03-types.raku`](03-types.raku) | It takes a DateTime and only a DateTime | checked |
| [`04-boundary.raku`](04-boundary.raku) | The one thing to know | checked |
| [`05-named.raku`](05-named.raku) | Where the two engines differ | checked |
