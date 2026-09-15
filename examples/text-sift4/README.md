# Text::Sift4 — the examples

Every example from [the Text::Sift4 page](https://raku.online/modules/text-sift4/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Text::Sift4   # or: zef install Text::Sift4
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
| [`02-speed.raku`](02-speed.raku) | What you buy and what you pay | checked |
| [`03-asymmetry.raku`](03-asymmetry.raku) | The one thing to know | checked |
| [`04-oob.raku`](04-oob.raku) | Where the two engines differ | checked |
