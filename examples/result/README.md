# Result — the examples

Every example from [the Result page](https://raku.online/modules/result/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Result   # or: zef install Result
rakupp 01-result.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-result.raku`](01-result.raku) | Constructing and inspecting | checked |
| [`02-chain.raku`](02-chain.raku) | Chaining | checked |
| [`03-capture.raku`](03-capture.raku) | Turning a throw into a Result | checked |
| [`04-bind-trap.raku`](04-bind-trap.raku) | The one thing to know | checked |
