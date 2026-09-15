# TinyID — the examples

Every example from [the TinyID page](https://raku.online/modules/tinyid/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install TinyID   # or: zef install TinyID
rakupp 01-basics.raku
```

Each file is run under Raku++ 3.28.0 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-basics.raku`](01-basics.raku) | Encoding | checked |
| [`02-properties.raku`](02-properties.raku) | The properties that hold | checked |
| [`03-canonical.raku`](03-canonical.raku) | The one thing to know | checked |
| [`04-refusals.raku`](04-refusals.raku) | What it refuses | checked |
| [`05-portable.raku`](05-portable.raku) | Where the two engines differ | checked |
