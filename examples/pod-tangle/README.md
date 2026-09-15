# Pod::Tangle — the examples

Every example from [the Pod::Tangle page](https://raku.online/modules/pod-tangle/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Pod::Tangle   # or: zef install Pod::Tangle
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Tangling | checked |
| [`02-abbreviated.raku`](02-abbreviated.raku) | The one thing to know | checked |
| [`03-guard.raku`](03-guard.raku) | Telling success from failure | checked |
| [`04-scope.raku`](04-scope.raku) | Where the two engines differ | checked |
