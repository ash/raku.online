# ML::ROCFunctions — the examples

Every example from [the ML::ROCFunctions page](https://raku.online/modules/ml-rocfunctions/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install ML::ROCFunctions   # or: zef install ML::ROCFunctions
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | From labels to rates | checked |
| [`02-auroc.raku`](02-auroc.raku) | AUROC | checked |
| [`03-mcc.raku`](03-mcc.raku) | The one thing to know | checked |
| [`04-separator.raku`](04-separator.raku) | The separator matters | checked |
| [`05-registry.raku`](05-registry.raku) | Where the two engines differ | checked |
