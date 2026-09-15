# Math::Polynomial::Chebyshev — the examples

Every example from [the Math::Polynomial::Chebyshev page](https://raku.online/modules/math-polynomial-chebyshev/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Math::Polynomial::Chebyshev   # or: zef install Math::Polynomial::Chebyshev
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Evaluating | checked |
| [`02-shapes.raku`](02-shapes.raku) | Three argument shapes | checked |
| [`03-exact.raku`](03-exact.raku) | The one thing to know | checked |
| [`04-trig.raku`](04-trig.raku) | `:method<trig>` costs the exactness | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
