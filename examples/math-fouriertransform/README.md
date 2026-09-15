# Math::FourierTransform — the examples

Every example from [the Math::FourierTransform page](https://raku.online/modules/math-fouriertransform/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Math::FourierTransform   # or: zef install Math::FourierTransform
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Transforming | checked |
| [`02-impulse.raku`](02-impulse.raku) | Transforming | checked |
| [`03-typed.raku`](03-typed.raku) | The one thing to know | checked |
| [`04-portable.raku`](04-portable.raku) | Where the two engines differ | checked |
