# Algorithm::DawkinsWeasel — the examples

Every example from [the Algorithm::DawkinsWeasel page](https://raku.online/modules/algorithm-dawkinsweasel/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install Algorithm::DawkinsWeasel   # or: zef install Algorithm::DawkinsWeasel
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Running it | checked |
| [`02-same-object.raku`](02-same-object.raku) | The one thing to know | checked |
| [`03-termination.raku`](03-termination.raku) | Things that will not terminate | checked |
| [`04-shapes.raku`](04-shapes.raku) | Two API shapes | checked |
