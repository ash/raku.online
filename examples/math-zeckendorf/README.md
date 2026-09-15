# Math::Zeckendorf — the examples

Every example from [the Math::Zeckendorf page](https://raku.online/modules/math-zeckendorf/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Math::Zeckendorf   # or: zef install Math::Zeckendorf
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Both representations | checked |
| [`02-dual.raku`](02-dual.raku) | Both representations | checked |
| [`03-numbers-lost.raku`](03-numbers-lost.raku) | The one thing to know | checked |
| [`04-shapes.raku`](04-shapes.raku) | Two shapes to know | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
