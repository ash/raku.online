# Math::SelfDescriptiveNumbers — the examples

Every example from [the Math::SelfDescriptiveNumbers page](https://raku.online/modules/math-selfdescriptivenumbers/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Math::SelfDescriptiveNumbers   # or: zef install Math::SelfDescriptiveNumbers
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Asking | checked |
| [`02-check.raku`](02-check.raku) | Asking | checked |
| [`03-int-vs-str.raku`](03-int-vs-str.raku) | The one thing to know | checked |
| [`04-shape.raku`](04-shape.raku) | The return shape changes with the base | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
