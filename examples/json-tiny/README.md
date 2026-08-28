# JSON::Tiny — the examples

Every example from [the JSON::Tiny page](https://raku.online/modules/json-tiny/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install JSON::Tiny   # or: zef install JSON::Tiny
rakupp 01-round-trip.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-round-trip.raku`](01-round-trip.raku) | What it is for | checked |
| [`02-number-types.raku`](02-number-types.raku) | Numbers come back typed | checked |
| [`03-invalid-input.raku`](03-invalid-input.raku) | Numbers come back typed | checked |
| [`04-json-with-comments.raku`](04-json-with-comments.raku) | Subclass it: JSON with comments | checked |
