# JSON::Native — the examples

Every example from [the JSON::Native page](https://raku.online/modules/json-native/), one file each. They are
generated from that page, so they cannot drift from it — and each one is a
complete program: no scaffolding to add, nothing to uncomment.

```sh
rakupp install JSON::Native   # or: zef install JSON::Native
rakupp 01-tour.raku
```

Each file is run under Raku++ 3.20.1 and under Rakudo 2026.08, twice on each,
whenever the site is built. A file whose output has moved fails that build, so
the "Output:" comment at the bottom of a file is what it printed, not what it
was once expected to print. The ones marked *varies* draw random numbers —
they are run, but their output is not compared.

| File | Section | Output |
|---|---|---|
| [`01-tour.raku`](01-tour.raku) | What it is for | checked |
| [`02-backend.raku`](02-backend.raku) | Three backends, and who is answering | varies (random) |
| [`03-types.raku`](03-types.raku) | The types you get back are JSON::Fast's | checked |
| [`04-byte-for-byte.raku`](04-byte-for-byte.raku) | Byte for byte, checked against the original | checked |
| [`05-immutable.raku`](05-immutable.raku) | `:immutable` is claimed; everything else is delegated | checked |
| [`06-delegate.raku`](06-delegate.raku) | `:immutable` is claimed; everything else is delegated | checked |
