# Math::BijectiveBase — the examples

Every example from [the Math::BijectiveBase page](https://raku.online/modules/math-bijectivebase/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Math::BijectiveBase   # or: zef install Math::BijectiveBase
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Converting | checked |
| [`02-base36.raku`](02-base36.raku) | The one thing to know | checked |
| [`03-alphabets.raku`](03-alphabets.raku) | Two more alphabet surprises | checked |
| [`04-portable.raku`](04-portable.raku) | Where the two engines differ | checked |
