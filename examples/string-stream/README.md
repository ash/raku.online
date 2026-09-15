# String::Stream — the examples

Every example from [the String::Stream page](https://raku.online/modules/string-stream/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install String::Stream   # or: zef install String::Stream
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
| [`02-fresh.raku`](02-fresh.raku) | Using it | checked |
| [`03-capture.raku`](03-capture.raku) | The one thing to know | checked |
| [`04-constructor.raku`](04-constructor.raku) | Where the two engines differ | checked |
